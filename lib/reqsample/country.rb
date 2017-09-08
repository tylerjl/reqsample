require 'json'
require 'ipaddr'
require 'rubystats'

module ReqSample
  class Countries
    attr_accessor :codes, :connectivity, :dist, :networks

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

    def initialize
      vendor = File.expand_path('../../../vendor', __FILE__)

      # Peak at zero (will be summed with the Time object)
      @dist = Rubystats::NormalDistribution.new(0, 2.5)

      @codes = RESPONSE_CODES.map do |code, weight|
        [
          code,
          (Float weight) / RESPONSE_CODES.values.reduce(:+)
        ]
      end.to_h

      populations = JSON.parse(
        File.read(File.join(vendor, 'country_connectivity.json'))
      )
      total_population = populations.values.reduce(:+)
      @connectivity = populations.map do |country, population|
        [
          country,
          (Float population) / total_population
        ]
      end.to_h

      @networks = JSON.parse(
        File.read(File.join(vendor, 'country_networks.json'))
      )
    end

    def sample(options = {})
      country = sample_country
      sample = {
        :address => sample_address(country),
        :code => sample_code,
        :time => sample_time(options)
      }

      case options[:format]
      when :apache
        %Q|#{sample[:address]} - user [#{sample[:time].strftime('%d/%b/%Y:%H:%M:%S %z')}] "GET / HTTP/1.1" #{sample[:code]} 10 "http://tjll.net" "curl"|
      else
        { country => sample }
      end
    end

    def sample_code
      weighted_sample(codes)
    end

    def sample_country
      weighted_sample(connectivity)
    end

    def sample_address(country = nil)
      country ||= networks.keys.sample

      head, tail = networks[country].sample
      IPAddr.new(
        rand(IPAddr.new(head).to_i..IPAddr.new(tail).to_i),
        Socket::AF_INET
      )
    end

    def sample_time(options = {})
      options[:peak] ||= Time.now
      options[:truncate] ||= 12

      loop do
        sample = options[:peak] + (dist.rng * 60 * 60)
        break sample if time_within options[:peak], sample, options[:truncate]
      end
    end

    private

    def time_within(center, test, limit)
      seconds_range = limit * 60 * 60
      (center - seconds_range) <= test && test <= (center + seconds_range)
    end

    def weighted_sample(collection)
      collection.max_by do |_, weight|
        rand**(1.0 / weight)
      end.first
    end
  end
end
