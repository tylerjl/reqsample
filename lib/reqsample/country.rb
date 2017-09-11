require 'json'
require 'ipaddr'
require 'rubystats'

require 'reqsample/hash'
require 'reqsample/time'

module ReqSample
  class Countries
    attr_accessor :agents, :codes, :connectivity, :dist, :max_bytes, :networks

    DEFAULT_MAX_BYTES = 512

    # These probabilities are purely random guesses
    RESPONSE_CODES = {
      '200' => 100,
      '204' => 1,
      '301' => 5,
      '302' => 10,
      '304' => 30,
      '400' => 3,
      '401' => 2,
      '403' => 6,
      '404' => 13,
      '429' => 3,
      '500' => 2,
      '502' => 7,
      '503' => 3,
      '504' => 3
    }.freeze

    def vendor(file)
      v = File.expand_path('../../../vendor', __FILE__)
      JSON.parse(File.read(File.join(v, file)))
    end

    def initialize(peak_sd = 4.0)
      @agents = ReqSample::Hash.weighted(vendor('user_agents.json'))
      @codes = ReqSample::Hash.weighted(RESPONSE_CODES)
      # Peak at zero (will be summed with the Time object)
      @connectivity = ReqSample::Hash.weighted(
        vendor('country_connectivity.json')
      )
      @dist = Rubystats::NormalDistribution.new(0, peak_sd)
      @max_bytes = DEFAULT_MAX_BYTES
      @networks = vendor('country_networks.json')
    end

    def generate(opts = {})
      opts[:count] ||= 1000
      opts[:format] ||= :apache

      1.upto(opts[:count]).map do |_|
        sample_time opts[:peak], opts[:truncate]
      end.sort.map do |time|
        sample time, opts[:format]
      end
    end

    def sample(time = nil, fmt = nil)
      # Pull a random country, but ensure it's a valid country code for the
      # list of networks that we have available.
      country = connectivity.weighted_sample do |ccodes|
        ccodes.detect do |ccode|
          networks.keys.include? ccode
        end
      end

      sample = {
        address: sample_address(country),
        agent: agents.weighted_sample,
        bytes: rand(max_bytes),
        code: codes.weighted_sample,
        time: time || sample_time(opts)
      }

      format fmt, country, sample
    end

    def format(style, country, sample)
      case style.to_s
      when 'apache'
        [
          "#{sample[:address]} - user",
          "[#{sample[:time].strftime('%d/%b/%Y:%H:%M:%S %z')}]",
          %("GET / HTTP/1.1"),
          sample[:code],
          sample[:bytes],
          %("http://tjll.net"),
          %("#{sample[:agent]}")
        ].join ' '
      else
        { country => sample }
      end
    end

    def sample_address(country = nil)
      country ||= networks.keys.sample

      head, tail = networks[country].sample
      IPAddr.new(
        rand(IPAddr.new(head).to_i..IPAddr.new(tail).to_i),
        Socket::AF_INET
      )
    end

    # Limit the normal distribution to +/- 12 hours (assume we want to stay
    # within a 24-hour period).
    def sample_time(peak = Time.now, truncate = 12)
      loop do
        sample = ReqSample::Time.at((peak + (dist.rng * 60 * 60)).to_i)
        break sample if sample.within peak, truncate
      end
    end
  end
end
