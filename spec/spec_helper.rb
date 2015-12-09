# coding: utf-8

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed
end

Dir[File.join(File.dirname(__FILE__), 'support', '*')].each do |path|
  require path
end

require 'simplecov'
SimpleCov.coverage_dir(File.join('spec', 'coverage'))

if ENV['CI']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/bundle/'
end

# Initialize Guard for running tests.
require 'guard'
Guard.setup(notify: false)

require 'guard/rubocop'
