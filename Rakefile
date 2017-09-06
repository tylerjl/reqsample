# encoding: utf-8

require 'rubygems'

begin
  require 'bundler/setup'
rescue LoadError => e
  abort e.message
end

require 'json'
require 'mechanize'
require 'rake'

require 'rubygems/tasks'
Gem::Tasks.new

require 'rdoc/task'
RDoc::Task.new
task :doc => :rdoc

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :test    => :spec
task :default => :spec

desc 'Load in country IP ranges into a unified JSON dump.'
task :load_country_networks do
  agent = Mechanize.new
  agent.get(URI('http://www.nirsoft.net/countryip/')) do |page|
    page.links_with(:href => /^[a-z]{2}[.]html$/).reduce({}) do |h, country|
      h[country.href.split('.').first] = country.click
        .link_with(:href => /[.]csv$/).click.body
        .strip.split("\n").map(&:strip).map do |ips|
          ips.split(',')[0..1]
        end
      h
    end.tap do |network_hash|
      File.open('vendor/country_networks.json', 'w') do |fh|
        fh.write JSON.dump(network_hash)
      end
    end
  end
end
