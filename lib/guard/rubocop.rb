# coding: utf-8

require 'guard'
require 'guard/guard'
require 'guard/notifier'

module Guard
  class Rubocop < Guard
    # rubocop:disable SymbolSnakeCase
    autoload :Runner, 'guard/rubocop/runner'
    # rubocop:enable SymbolSnakeCase

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

      runner = Runner.new(@options)
      passed = runner.run
      @failed_paths = runner.failed_paths

      throw :task_has_failed unless passed
    end

    def run_on_changes(paths)
      paths += @failed_paths if @options[:keep_failed]
      paths.map! { |path| File.expand_path(path) }
      paths.uniq!

      UI.info "Checking Ruby code styles: #{paths.join(' ')}"

      runner = Runner.new(@options)
      passed = runner.run(paths)
      @failed_paths = runner.failed_paths

      throw :task_has_failed unless passed
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

    def included_in_other_path?(target_path, other_paths)
      dir_paths = other_paths.select { |path| File.directory?(path) }
      dir_paths.delete(target_path)
      dir_paths.any? do |dir_path|
        target_path.start_with?(dir_path)
      end
    end
  end
end
