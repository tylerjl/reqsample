require 'json'
require 'ipaddr'
require 'rubystats'

require 'reqsample/hash'
require 'reqsample/response_codes'
require 'reqsample/request_paths'
require 'reqsample/request_verbs'
require 'reqsample/time'

# Top-level module for ReqSample constants and classes.
module ReqSample
  # Main class for creating randomized data.
  class Generator
    attr_accessor :agents,
                  :codes,
                  :connectivity,
                  :dist,
                  :max_bytes,
                  :networks,
                  :verbs

    DEFAULT_COUNT = 1000
    DEFAULT_DOMAIN = 'http://example.com'.freeze
    DEFAULT_FORMAT = :apache
    DEFAULT_MAX_BYTES = 512

    # @param peak_sd [Float] standard deviation in the normal distribution
    def initialize(peak_sd = 4.0)
      @agents = ReqSample::Hash.weighted(vendor('user_agents.json'))
      @codes = ReqSample::Hash.weighted(ReqSample::RESPONSE_CODES)
      # Peak at zero (will be summed with the Time object)
      @connectivity = ReqSample::Hash.weighted(
        vendor('country_connectivity.json')
      )
      @dist = Rubystats::NormalDistribution.new(0, peak_sd)
      @max_bytes = DEFAULT_MAX_BYTES
      @networks = vendor('country_networks.json')
      @verbs = ReqSample::Hash.weighted(ReqSample::REQUEST_VERBS)
    end

    # @option opts [Integer] :count how many logs to generate
    # @option opts [String] :format form to return logs, :apache or :hash
    # @option opts [Time] :peak normal distribution peak for log timestamps
    # @option opts [Integer] :truncate hard limit to keep log range within
    #
    # @return [Array<String, Hash>] the collection of generated log events
    def produce(opts = {})
      opts[:count] ||= DEFAULT_COUNT
      opts[:format] ||= DEFAULT_FORMAT
      opts[:peak] ||= Time.now - (12 * 60 * 60)
      opts[:truncate] ||= 12

      1.upto(opts[:count]).map do |_|
        sample_time opts[:peak], opts[:truncate]
      end.sort.map do |time|
        if block_given?
          if (delay = time - Time.now) > 0 then sleep delay end
          yield sample time, opts[:format]
        else
          sample time, opts[:format]
        end
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
        domain: DEFAULT_DOMAIN,
        path: ReqSample::REQUEST_PATHS.sample,
        time: time || sample_time(opts),
        verb: verbs.weighted_sample
      }

      format fmt, country, sample
    end

    def format(style, country, sample)
      case style.to_s
      when 'apache'
        [
          "#{sample[:address]} - -",
          "[#{sample[:time].strftime('%d/%b/%Y:%H:%M:%S %z')}]",
          %("#{sample[:verb]} #{sample[:path]} HTTP/1.1"),
          sample[:code],
          sample[:bytes],
          %("#{sample[:domain]}"),
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
    def sample_time(peak, truncate)
      loop do
        sample = ReqSample::Time.at((peak + (dist.rng * 60 * 60)).to_i)
        break sample if sample.within peak, truncate
      end
    end
  end

  private

  def vendor(file)
    v = File.expand_path('../../../vendor', __FILE__)
    JSON.parse(File.read(File.join(v, file)))
  end
end
