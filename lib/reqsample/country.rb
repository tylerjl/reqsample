require 'json'
require 'ipaddr'

module ReqSample
  class Countries
    attr_accessor :codes, :connectivity, :networks

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

    def sample
      country = sample_country
      {
        country => {
          :address => sample_address(country),
          :code => sample_code
        }
      }
    end

    def sample_code
      codes.max_by do |_, weight|
        rand**(1.0 / weight)
      end.first
    end

    def sample_country
      connectivity.max_by do |_, weight|
        rand**(1.0 / weight)
      end.first
    end

    def sample_address(country = nil)
      country ||= networks.keys.sample

      head, tail = networks[country].sample
      IPAddr.new(
        rand(IPAddr.new(head).to_i..IPAddr.new(tail).to_i),
        Socket::AF_INET
      )
    end
  end
end
