RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  # config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end

Dir[File.join(File.dirname(__FILE__), 'support', '*')].each do |path|
  require path
end

require 'simplecov'
SimpleCov.coverage_dir(File.join('spec', 'coverage'))

if ENV['TRAVIS']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
elsif ENV['CI']
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/bundle/'
end
