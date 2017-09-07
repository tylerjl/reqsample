require 'json'
require 'ipaddr'

module ReqSample
  class Countries
    attr_accessor :networks, :connectivity

    def initialize
      vendor = File.expand_path('../../../vendor', __FILE__)

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
      { country => sample_address(country) }
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
