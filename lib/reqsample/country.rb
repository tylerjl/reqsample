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

    def initialize(peak_sd = 2.5)
      @agents = ReqSample::Hash.weighted(vendor('user_agents.json'))
      @codes = ReqSample::Hash.weighted(RESPONSE_CODES)
      # Peak at zero (will be summed with the Time object)
      @dist = Rubystats::NormalDistribution.new(0, peak_sd)
      @connectivity = ReqSample::Hash.weighted(
        vendor('country_connectivity.json')
      )
      @max_bytes = DEFAULT_MAX_BYTES
      @networks = vendor('country_networks.json')
    end

    def sample(opts = {})
      country = connectivity.weighted_sample
      sample = {
        address: sample_address(country),
        agent: agents.weighted_sample,
        bytes: rand(max_bytes),
        code: codes.weighted_sample,
        time: sample_time(opts)
      }

      format opts[:format], country, sample
    end

    def format(style, country, sample)
      case style
      when :apache
        %Q|#{sample[:address]} - user [#{sample[:time].strftime('%d/%b/%Y:%H:%M:%S %z')}] "GET / HTTP/1.1" #{sample[:code]} #{sample[:bytes]} "http://tjll.net" "#{sample[:agent]}"|
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

    def sample_time(opts = {})
      opts[:peak] ||= Time.now
      # Limit the normal distribution to +/- 12 hours (assume we want to stay
      # within a 24-hour period).
      opts[:truncate] ||= 12

      loop do
        sample = ReqSample::Time.at((opts[:peak] + (dist.rng * 60 * 60)).to_i)
        break sample if sample.within opts[:peak], opts[:truncate]
      end
    end
  end
end
