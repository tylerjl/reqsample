require 'json'
require 'ipaddr'

module ReqSample
  class Countries
    attr_accessor :countries

    def initialize
      vendor = File.expand_path('../../../vendor', __FILE__)
      @countries = JSON.parse(
        File.read(File.join(vendor, 'country_networks.json'))
      )
    end

    def sample(country = nil)
      country ||= countries.keys.sample

      head, tail = countries[country].sample
      IPAddr.new(
        rand(IPAddr.new(head).to_i..IPAddr.new(tail).to_i),
        Socket::AF_INET
      )
    end
  end
end
