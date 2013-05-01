# coding: utf-8

require 'childprocess'

module Guard
  class Rubocop
    class Runner
      PASSED_EXIT_CODE = 0
      MINIMUM_POLL_INTERVAL = 0.1

      attr_reader :passed, :output

      alias_method :passed?, :passed

      def initialize(options)
        @options = options
      end

      def run(paths = [])
        exit_code, @output = rubocop(['--no-color'].concat(paths))
        @passed = (exit_code == PASSED_EXIT_CODE)

        case @options[:notification]
        when :failed
          notify unless passed?
        when true
          notify
        end

        passed
      end

      def rubocop(args)
        process = ChildProcess.build('rubocop', *args)

        stdout_reader, stdout_writer = IO.pipe
        process.io.stdout = stdout_writer

        process.start

        output = ''

        loop do
          output << capture_and_print_output(stdout_reader)
          break if process.exited?
        end

        [process.exit_code, output]
      end

      def notify
        image = passed ? :success : :failed
        Notifier.notify(summary, title: 'RuboCop results', image: image)
      end

      def summary
        return nil unless output
        output.lines.to_a.last.chomp
      end

      def failed_paths
        return [] unless output
        output.scan(/^== (.+) ==$/).flatten
      end

      private

      def capture_and_print_output(output)
        available_ios, = IO.select([output], nil, nil, MINIMUM_POLL_INTERVAL)
        return '' unless available_ios
        chunk = available_ios.first.read_available_nonblock
        $stdout.write chunk
        chunk
      end

      class IO < ::IO
        READ_CHUNK_SIZE = 10000

        def read_available_nonblock
          data = ''
          loop do
            begin
              data << read_nonblock(READ_CHUNK_SIZE)
            rescue ::IO::WaitReadable, EOFError
              return data
            end
          end
        end
      end

    end
  end
end
