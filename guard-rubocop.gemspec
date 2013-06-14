# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'guard/rubocop/version'

Gem::Specification.new do |spec|
  spec.name          = 'guard-rubocop'
  spec.version       = Guard::RubocopVersion::VERSION
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']
  spec.summary       = 'Guard plugin for RuboCop'
  spec.description   = 'Guard::Rubocop allows you to automatically check Ruby code style with RuboCop when files are modified.'
  spec.homepage      = 'https://github.com/yujinakayama/guard-rubocop'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency "guard",          '~> 1.8'
  spec.add_runtime_dependency "rubocop",        ['>= 0.6.1', '< 1.0.0']
  spec.add_runtime_dependency "childprocess",   '~> 0.3'
  spec.add_runtime_dependency "term-ansicolor", '~> 1.1'

  spec.add_development_dependency 'bundler',     '~> 1.3'
  spec.add_development_dependency 'rake',        '~> 10.0'
  spec.add_development_dependency 'rspec',       '~> 2.13'
  spec.add_development_dependency 'simplecov',   '~> 0.7'
  spec.add_development_dependency 'guard-rspec', '~> 3.0'
  spec.add_development_dependency 'ruby_gntp',   '~> 0.3'
end
