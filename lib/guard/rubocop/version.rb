# coding: utf-8

module Guard
  # A workaround for declaring `class RuboCop`
  # before `class RuboCop < Guard` in rubocop.rb
  module RuboCopVersion
    # http://semver.org/
    MAJOR = 1
    MINOR = 2
    PATCH = 0

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
