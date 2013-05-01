# coding: utf-8

module Guard
  # A workaround for declaring `class Rubocop`
  # before `class Rubocop < Guard` in rubocop.rb
  module RubocopVersion
    # http://semver.org/
    MAJOR = 0
    MINOR = 0
    PATCH = 3
    VERSION = [MAJOR, MINOR, PATCH].join('.')
  end
end
