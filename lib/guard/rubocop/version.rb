# coding: utf-8

module Guard
  # A workaround for declaring `class Rubocop`
  # before `class Rubocop < Guard` in rubocop.rb
  module RubocopVersion
    # http://semver.org/
    MAJOR = 0
    MINOR = 1
    PATCH = 0
    VERSION = [MAJOR, MINOR, PATCH].join('.')
  end
end
