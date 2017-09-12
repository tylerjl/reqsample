# encoding: utf-8

require 'rubygems'

begin
  require 'bundler/setup'
rescue LoadError => e
  abort e.message
end

require 'json'
require 'iso_country_codes'
require 'mechanize'
require 'open-uri'
require 'rake'

COUNTRY_CONNECTIVITY = 'https://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'.freeze
CONNECTIVITY_XPATH = '//h2[span[contains(text(), "List")]]/following-sibling::table/tr[not(descendant::th)]'.freeze
USER_AGENTS = 'https://techblog.willshouse.com/2012/01/03/most-common-user-agents/'

require 'rubygems/tasks'
Gem::Tasks.new

require 'rdoc/task'
RDoc::Task.new
task :doc => :rdoc

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :test    => :spec
task :default => :spec

task :pry do
  require 'pry'
  require 'reqsample'
  subject = ReqSample::Generator.new
  ARGV.clear
  binding.pry
end

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

desc 'Retrieve list of internet-connected users by Country.'
task :load_country_connectivity do
  Nokogiri::HTML(open(COUNTRY_CONNECTIVITY)).tap do |page|
    page.xpath(CONNECTIVITY_XPATH).map do |row|
      [
        IsoCountryCodes.search_by_name(
          case (c = row.xpath('td')[0].xpath('a').text.strip.downcase)
          when 'vietnam' then 'viet nam'
          when 'south korea' then 'korea (republic'
          when 'czech republic' then 'czech'
          when 'ivory coast' then 'côte'
          when 'laos' then 'lao'
          when /congo/ then 'congo'
          when /gambia/ then 'gambia'
          when /bahama/ then 'bahama'
          when /são/ then 'sao'
          else c
          end
        ).first.alpha2.downcase,
        row.xpath('td')[1].text.delete(',').to_i
      ]
    end.to_h.tap do |statistics|
      File.open('vendor/country_connectivity.json', 'w') do |fh|
        fh.write JSON.dump(statistics)
      end
    end
  end
end

desc 'Retrieve list of common User-Agents.'
task :load_user_agents do
  Nokogiri::HTML(open(USER_AGENTS)).tap do |page|
    page.at_css('.most-common-user-agents').xpath('tbody/tr').map do |row|
      [
        row.at_css('.useragent').text.strip,
        row.at_css('.percent').text.strip.chomp('%').to_f
      ]
    end.to_h.tap do |list|
      File.open('vendor/user_agents.json', 'w') do |fh|
        fh.write JSON.dump(list)
      end
    end
  end
end
