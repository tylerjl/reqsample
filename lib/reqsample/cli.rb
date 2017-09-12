require 'chronic'
require 'thor'
require 'reqsample'

module ReqSample
  # Command-line interface to the library
  class CLI < Thor
    class_option :count,
                 default: 1000,
                 type: :numeric
    class_option :format,
                 default: :apache,
                 desc: 'Output format of generated logs'
    class_option :stdev,
                 default: 4,
                 desc: 'Standard deviation to use for timespan normal distribution',
                 type: :numeric
    class_option :truncate,
                 default: 12,
                 desc: 'Cutoff (in hours) that logs should remain +/- within',
                 type: :numeric

    option :peak,
           default: '12 hours ago',
           desc: 'Time at which logs should peak (Chronic-style strings)'
    desc 'generate', 'Generate a sample of webserver logs'
    def generate
      opts = options.dup
      opts[:peak] = Chronic.parse options[:peak]
      puts ReqSample::Generator.new(options[:stdev]).produce(opts).join("\n")
    end

    option :peak,
           default: 'in 12 hours',
           desc: 'Time at which logs should peak (Chronic-style strings)'
    desc 'stream', 'Gradually stream generated logs over given time'
    def stream
      opts = options.dup
      opts[:peak] = Chronic.parse options[:peak]
      ReqSample::Generator.new(options[:stdev]).produce(opts) do |log|
        puts log
      end
    end
  end
end
