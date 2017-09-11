require 'chronic'
require 'thor'
require 'reqsample'

module ReqSample
  # Command-line interface to the library
  class CLI < Thor
    desc 'generate', 'Generate a sample of webserver logs'
    option :count,
           default: 1000,
           type: :numeric
    option :format,
           default: :apache,
           desc: 'Output format of generated logs'
    option :peak,
           default: '12 hours ago',
           desc: 'Time at which logs should peak (Chronic-style strings)'
    option :stdev,
           default: 4,
           desc: 'Standard deviation to use for timespan normal distribution'
    option :truncate,
           default: 12,
           desc: 'Cutoff (in hours) that logs should remain +/- within',
           type: :numeric
    def generate
      opts = options.dup
      opts[:peak] = Chronic.parse options[:peak]
      puts ReqSample::Countries.new(options[:stdev]).generate(opts).join("\n")
    end
  end
end
