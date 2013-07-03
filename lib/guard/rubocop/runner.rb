# coding: utf-8

require 'json'

module Guard
  class Rubocop
    class Runner
      def initialize(options)
        @options = options
      end

      def run(paths = [])
        command = build_command(paths)
        passed = system(*command)

        case @options[:notification]
        when :failed
          notify(passed) unless passed
        when true
          notify(passed)
        end

        passed
      end

      def build_command(paths)
        command = ['rubocop']
        command.concat(%w(--format progress)) # Keep default formatter for console.
        command.concat(['--format', 'json', '--out', json_file_path])
        command.concat(paths)
      end

      def json_file_path
        @tempfile_path ||= begin
          # Just generate random tempfile path.
          basename = self.class.name.downcase.gsub('::', '_')
          tempfile = Tempfile.new(basename)
          tempfile.close
          tempfile.path
        end
      end

      def result
        @result ||= begin
          File.open(json_file_path) do |file|
            # Rubinius 2.0.0.rc1 does not support `JSON.load` with 3 args.
            JSON.parse(file.read, symbolize_names: true)
          end
        end
      end

      def notify(passed)
        image = passed ? :success : :failed
        Notifier.notify(summary_text, title: 'RuboCop results', image: image)
      end

      def summary_text
        summary = result[:summary]

        text = pluralize(summary[:inspected_file_count], 'file')
        text << ' inspected, '

        text << pluralize(summary[:offence_count], 'offence', no_for_zero: true)
        text << ' detected'
      end

      def failed_paths
        failed_files = result[:files].reject do |file|
          file[:offences].empty?
        end
        failed_files.map do |file|
          file[:path]
        end
      end

      def pluralize(number, thing, options = {})
        text = ''

        if number == 0 && options[:no_for_zero]
          text = 'no'
        else
          text << number.to_s
        end

        text << " #{thing}"
        text << 's' unless number == 1

        text
      end
    end
  end
end
