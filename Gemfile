source 'https://rubygems.org'

gemspec

group :test do
  gem 'coveralls',      '~> 0.6'
  gem 'simplecov-rcov', '~> 0.2'
  gem 'ci_reporter',    '~> 1.8'

  gem 'rubocop', github: 'bbatsov/rubocop' if RUBY_VERSION.start_with?('2.1')
  gem 'rubysl', platform: :rbx
  gem 'rubinius-developer_tools', platform: :rbx
  gem 'racc', platform: :rbx
end
