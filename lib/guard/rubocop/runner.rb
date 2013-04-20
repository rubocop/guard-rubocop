# coding: utf-8

require 'childprocess'
require 'term/ansicolor'

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
        exit_code, output = rubocop(paths)
        @passed = (exit_code == PASSED_EXIT_CODE)
        @output = Term::ANSIColor.uncolor(output)

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

        ios = [stdout_reader]
        output = ''

        loop do
          available_ios, = IO.select(ios, nil, nil, MINIMUM_POLL_INTERVAL)

          if available_ios
            available_ios.each do |io|
              chunk = io.read_available_nonblock
              $stdout.write chunk
              output << chunk
            end
          end

          break if process.exited?
        end

        [process.exit_code, output]
      end

      def notify
        image = passed ? :success : :failed
        Notifier.notify(summary, title: 'Rubocop results', image: image)
      end

      def summary
        return nil unless output
        output.lines.to_a.last.chomp
      end

      def failed_paths
        return [] unless output
        output.scan(/^== (.+) ==$/).flatten
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
