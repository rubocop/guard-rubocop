source 'https://rubygems.org'

gemspec

group :test do
  gem 'coveralls',      '~> 0.6'
  gem 'simplecov-rcov', '~> 0.2'
  gem 'ci_reporter',    '~> 1.8'
end

platforms :rbx do
  gem 'rubysl'
  gem 'rubinius-developer_tools'
  gem 'json'
  gem 'racc' # Needed for RuboCop
end
