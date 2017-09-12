# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reqsample/version'

Gem::Specification.new do |gem|
  gem.name          = 'reqsample'
  gem.version       = ReqSample::VERSION
  gem.summary       = %(Generate somewhat-realistic sample HTTP traffic.)
  gem.description   = %(Generate somewhat-realistic sample HTTP traffic.)
  gem.license       = 'MIT'
  gem.authors       = ['Tyler Langlois']
  gem.email         = 'tjl@byu.net'
  gem.homepage      = 'https://rubygems.org/gems/reqsample'

  gem.files         = `git ls-files`.split($RS)

  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'chronic'
  gem.add_dependency 'rubystats'
  gem.add_dependency 'thor'

  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'bundler', '~> 1.10'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'iso_country_codes'
  gem.add_development_dependency 'mechanize'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rdoc', '~> 4.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end
