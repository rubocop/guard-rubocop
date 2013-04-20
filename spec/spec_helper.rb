# coding: utf-8

class NoExpectationExecutedError < StandardError
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Original snippet by sorah
  # https://gist.github.com/sorah/4315150
  config.after do
    result = self.example.metadata[:execution_result]

    has_mock_expectations = !RSpec::Mocks.space.instance_eval do
      receivers
    end.empty?

    next if result[:exception]
    next if result[:pending_message]
    next if RSpec::Matchers.last_should
    next if has_mock_expectations

    fail NoExpectationExecutedError
  end
end

Dir[File.join(File.dirname(__FILE__), 'support', '*')].each do |path|
  require path
end

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

require 'guard/rubocop'
