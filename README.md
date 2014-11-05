[![Gem Version](http://img.shields.io/gem/v/guard-rubocop.svg)](http://badge.fury.io/rb/guard-rubocop)
[![Dependency Status](http://img.shields.io/gemnasium/yujinakayama/guard-rubocop.svg)](https://gemnasium.com/yujinakayama/guard-rubocop)
[![Build Status](https://travis-ci.org/yujinakayama/guard-rubocop.svg?branch=master)](https://travis-ci.org/yujinakayama/guard-rubocop)
[![Coverage Status](http://img.shields.io/coveralls/yujinakayama/guard-rubocop/master.svg)](https://coveralls.io/r/yujinakayama/guard-rubocop)
[![Code Climate](http://img.shields.io/codeclimate/github/yujinakayama/guard-rubocop.svg)](https://codeclimate.com/github/yujinakayama/guard-rubocop)

# guard-rubocop

**guard-rubocop** allows you to automatically check Ruby code style with [RuboCop](https://github.com/bbatsov/rubocop) when files are modified.

Tested on MRI 1.9, 2.0, 2.1, JRuby in 1.9 mode and Rubinius.

## Installation

Please make sure to have [Guard](https://github.com/guard/guard) installed before continue.

Add `guard-rubocop` to your `Gemfile`:

```ruby
group :development do
  gem 'guard-rubocop'
end
```

and then execute:

```sh
$ bundle install
```

or install it yourself as:

```sh
$ gem install guard-rubocop
```

Add the default Guard::Rubocop definition to your `Guardfile` by running:

```sh
$ guard init rubocop
```

## Usage

Please read the [Guard usage documentation](https://github.com/guard/guard#readme).

## Options

You can pass some options in `Guardfile` like the following example:

```ruby
guard :rubocop, all_on_start: false, cli: ['--format', 'clang', '--rails'] do
  # ...
end
```

### Available Options

```ruby
all_on_start: true     # Check all files at Guard startup.
                       #   default: true
cli: '--rails'         # Pass arbitrary RuboCop CLI arguments.
                       # An array or string is acceptable.
                       #   default: nil
hide_stdout: false      # Do not display console output (in case outputting to file).
                       #   default: false
keep_failed: true      # Keep failed files until they pass.
                       #   default: true
notification: :failed  # Display Growl notification after each run.
                       #   true    - Always notify
                       #   false   - Never notify
                       #   :failed - Notify only when failed
                       #   default: :failed
```

## Advanced Tips

If you're using a testing Guard plugin such as [`guard-rspec`](https://github.com/guard/guard-rspec) together with `guard-rubocop` in the TDD way (the red-green-refactor cycle),
you might be uncomfortable with the offense reports from RuboCop in the red-green phase:

* In the red-green phase, you're not necessarily required to write clean code – you just focus writing code to pass the test. It means, in this phase, `guard-rspec` should be run but `guard-rubocop` should not.
* In the refactor phase, you're required to make the code clean while keeping the test passing. In this phase, both `guard-rspec` and `guard-rubocop` should be run.

In this case, you may think the following `Guardfile` structure useful:

```ruby
# This group allows to skip running RuboCop when RSpec failed.
group :red_green_refactor, halt_on_fail: true do
  guard :rspec do
    # ...
  end

  guard :rubocop do
    # ...
  end
end
```

Note: You need to use `guard-rspec` 4.2.3 or later due to a [bug](https://github.com/guard/guard-rspec/pull/234) where it unintentionally fails when there are no spec files to be run.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2013–2014 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
