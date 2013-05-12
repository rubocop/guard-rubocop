[![Gem Version](https://badge.fury.io/rb/guard-rubocop.png)](http://badge.fury.io/rb/guard-rubocop) [![Dependency Status](https://gemnasium.com/yujinakayama/guard-rubocop.png)](https://gemnasium.com/yujinakayama/guard-rubocop) [![Build Status](https://travis-ci.org/yujinakayama/guard-rubocop.png?branch=master)](https://travis-ci.org/yujinakayama/guard-rubocop) [![Coverage Status](https://coveralls.io/repos/yujinakayama/guard-rubocop/badge.png?branch=master)](https://coveralls.io/r/yujinakayama/guard-rubocop) [![Code Climate](https://codeclimate.com/github/yujinakayama/guard-rubocop.png)](https://codeclimate.com/github/yujinakayama/guard-rubocop)

# Guard::Rubocop

Guard::Rubocop allows you to automatically check Ruby code style with [RuboCop](https://github.com/bbatsov/rubocop) when files are modified.

Tested on MRI 1.9 and MRI 2.0, according to RuboCop.

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

You can pass some options in `Guardfile`:

```ruby
guard 'rubocop', all_on_start: false, notification: true do
  # ...
end
```

### Available Options

```ruby
all_on_start: true     # Check all files at Guard startup, default: true
keep_failed: true      # Keep failed files until they pass, default: true
notification: :failed  # Display Growl notification after each run
                       #   true    - Always notify
                       #   false   - Never notify
                       #   :failed - Notify only when failed
                       #   default: :failed
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
