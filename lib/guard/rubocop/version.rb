# coding: utf-8

module Guard
  # A workaround for declaring `class Rubocop`
  # before `class Rubocop < Guard` in rubocop.rb
  module RubocopVersion
    # http://semver.org/
    MAJOR = 0
    MINOR = 2
    PATCH = 2

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
