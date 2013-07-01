# coding: utf-8

require 'guard'
require 'guard/guard'

module Guard
  class Rubocop < Guard
    autoload :Runner, 'guard/rubocop/runner'

    attr_reader :options, :failed_paths

    def initialize(watchers = [], options = {})
      super

      @options = {
        all_on_start: true,
        keep_failed:  true,
        notification: :failed
      }.merge(options)

      @failed_paths = []
    end

    def start
      run_all if @options[:all_on_start]
    end

    def run_all
      UI.info 'Checking Ruby code style of all files'
      run
    end

    def run_on_changes(paths)
      paths += @failed_paths if @options[:keep_failed]
      paths = clean_paths(paths)
      UI.info "Checking Ruby code styles: #{paths.join(' ')}"
      run(paths)
    end

    def reload
      @failed_paths = []
    end

    def clean_paths(paths)
      paths = paths.dup
      paths.map! { |path| File.expand_path(path) }
      paths.uniq!
      paths.reject! do |path|
        included_in_other_path?(path, paths)
      end
      paths
    end

    private

    def run(paths = [])
      runner = Runner.new(@options)
      passed = runner.run(paths)
      @failed_paths = runner.failed_paths
      throw :task_has_failed unless passed
    rescue => error
      UI.error 'The following exception occurred while running guard-rubocop: ' +
               "#{error.backtrace.first} #{error.message} (#{error.class.name})"
    end

    def included_in_other_path?(target_path, other_paths)
      dir_paths = other_paths.select { |path| File.directory?(path) }
      dir_paths.delete(target_path)
      dir_paths.any? do |dir_path|
        target_path.start_with?(dir_path)
      end
    end
  end
end
