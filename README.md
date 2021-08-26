[![Gem Version](https://badge.fury.io/rb/guard-rubocop.svg)](http://badge.fury.io/rb/guard-rubocop)
[![CI](https://github.com/yujinakayama/guard-rubocop/workflows/CI/badge.svg)](https://github.com/yujinakayama/guard-rubocop/actions)
[![Coverage Status](https://coveralls.io/repos/yujinakayama/guard-rubocop/badge.svg?branch=master&service=github)](https://coveralls.io/github/yujinakayama/guard-rubocop?branch=master)
[![Code Climate](https://codeclimate.com/github/yujinakayama/guard-rubocop/badges/gpa.svg)](https://codeclimate.com/github/yujinakayama/guard-rubocop)

# guard-rubocop

**guard-rubocop** allows you to automatically check Ruby code style with [RuboCop](https://github.com/rubocop-hq/rubocop) when files are modified.

Tested on MRI 2.4 - 2.7.

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

Add the default Guard::RuboCop definition to your `Guardfile` by running:

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
cmd: './bin/rubocop'   # Pass custom cmd to run rubocop.
                       #   default: rubocop

hide_stdout: false     # Do not display console output (in case outputting to file).
                       #   default: false
keep_failed: true      # Keep failed files until they pass.
                       #   default: true
notification: :failed  # Display Growl notification after each run.
                       #   true    - Always notify
                       #   false   - Never notify
                       #   :failed - Notify only when failed
                       #   default: :failed
launchy: nil           # Filename to launch using Launchy after RuboCop runs.
                       #   default: nil
```

### Using Launchy to view results

guard-rubocop can be configured to launch a results file in lieu of or in addition to outputing results to the terminal.
Configure your Guardfile with the launchy option:

``` ruby
guard :rubocop, cli: %w(--format fuubar --format html -o ./tmp/rubocop_results.html), launchy: './tmp/rubocop_results.html' do
  # ...
end
```

## Advanced Tips

If you're using a testing Guard plugin such as [`guard-rspec`](https://github.com/guard/guard-rspec) together with `guard-rubocop` in the TDD way (the red-green-refactor cycle),
you might be uncomfortable with the offense reports from RuboCop in the red-green phase:

* In the red-green phase, you're not necessarily required to write clean code – you just focus writing code to pass the test. It means, in this phase, `guard-rspec` should be run but `guard-rubocop` should not.
* In the refactor phase, you're required to make the code clean while keeping the test passing. In this phase, both `guard-rspec` and `guard-rubocop` should be run.

In this case, you may consider making use of the [group method](https://github.com/guard/guard/wiki/Guardfile-DSL---Configuring-Guard#group) in your `Guardfile`:

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

Copyright (c) 2013–2020 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
