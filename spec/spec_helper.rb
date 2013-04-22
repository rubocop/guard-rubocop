# coding: utf-8

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

Dir[File.join(File.dirname(__FILE__), 'support', '*')].each do |path|
  require path
end

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.coverage_dir(File.join('spec', 'coverage'))

  if ENV['CI']
    require 'simplecov-rcov'
    SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  end

  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/bundle/'
  end
end

require 'guard/rubocop'
