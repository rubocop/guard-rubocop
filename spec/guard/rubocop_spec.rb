# coding: utf-8

require 'spec_helper.rb'

describe Guard::Rubocop, :silence_output do
  subject(:guard) { Guard::Rubocop.new(watchers, options) }
  let(:watchers) { [] }
  let(:options) { {} }

  let(:runner) { Guard::Rubocop::Runner.any_instance }

  describe '#options' do
    subject { super().options }

    context 'by default' do
      let(:options) { {} }
      its([:all_on_start]) { should be_true }
      its([:keep_failed])  { should be_true }
      its([:notification]) { should == :failed }
    end
  end

  describe '#start' do
    context 'when :all_on_start option is enabled' do
      let(:options) { { all_on_start: true } }

      it 'runs all' do
        guard.should_receive(:run_all)
        guard.start
      end
    end

    context 'when :all_on_start option is disabled' do
      let(:options) { { all_on_start: false } }

      it 'does nothing' do
        guard.should_not_receive(:run_all)
        guard.start
      end
    end
  end

  shared_examples 'processes after running', :processes_after_running do
    context 'when passed' do
      it 'throws nothing' do
        runner.stub(:run).and_return(true)
        expect { subject }.not_to throw_symbol
      end

      it 'clears failed paths' do
        runner.stub(:run).and_return(true)
        runner.stub(:failed_paths).and_return([])
        subject
        guard.failed_paths.should be_empty
      end
    end

    context 'when failed' do
      it 'throws symbol :task_has_failed' do
        runner.stub(:run).and_return(false)
        expect { subject }.to throw_symbol(:task_has_failed)
      end

      it 'keeps failed paths' do
        guard.stub(:throw)
        failed_paths = [
          'some_failed_file.rb',
          'dir/another_failed_file.rb'
        ]
        runner.stub(:run).and_return(false)
        runner.stub(:failed_paths).and_return(failed_paths)
        subject
        guard.failed_paths.should == failed_paths
      end
    end

    context 'when an exception is raised' do
      it 'prevents itself from firing' do
        runner.stub(:run).and_raise(RuntimeError)
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '#run_all', :processes_after_running do
    subject { super().run_all }

    before do
      runner.stub(:run).and_return(true)
      runner.stub(:failed_paths).and_return([])
    end

    it 'inspects all files with rubocop' do
      runner.should_receive(:run).with([])
      guard.run_all
    end
  end

  describe '#run_on_changes', :processes_after_running do
    subject { super().run_on_changes(changed_paths) }
    let(:changed_paths) { ['some.rb', 'dir/another.rb', 'dir/../some.rb'] }

    before do
      runner.stub(:run).and_return(true)
      runner.stub(:failed_paths).and_return([])
    end

    it 'inspects changed files with rubocop' do
      runner.should_receive(:run)
      guard.run_on_changes(changed_paths)
    end

    it 'passes cleaned paths to rubocop' do
      runner.should_receive(:run) do |paths|
        paths.should == [
          File.expand_path('some.rb'),
          File.expand_path('dir/another.rb')
        ]
      end
      guard.run_on_changes(changed_paths)
    end

    let(:failed_path) { File.expand_path('failed_file_last_time.rb') }

    context 'when :keep_failed option is enabled' do
      let(:options) { { keep_failed: true } }

      it 'also inspects paths which are failed last time' do
        guard.failed_paths << failed_path
        runner.should_receive(:run) do |paths|
          paths.should include failed_path
        end
        guard.run_on_changes(changed_paths)
      end
    end

    context 'when :keep_failed option is disabled' do
      let(:options) { { keep_failed: false } }
      let(:changed_paths) do
        [
          File.expand_path('some.rb'),
          File.expand_path('dir/another.rb')
        ]
      end

      it 'inspects just changed paths' do
        guard.failed_paths << failed_path
        runner.should_receive(:run) do |paths|
          paths.should == changed_paths
        end
        guard.run_on_changes(changed_paths)
      end
    end
  end

  describe '#reload' do
    it 'clears failed paths' do
      guard.failed_paths << 'failed.rb'
      guard.reload
      guard.failed_paths.should be_empty
    end
  end

  describe '#clean_paths' do
    it 'converts to absolute paths' do
      paths = [
        'lib/guard/rubocop.rb',
        'spec/spec_helper.rb'
      ]
      guard.clean_paths(paths).should == [
        File.expand_path('lib/guard/rubocop.rb'),
        File.expand_path('spec/spec_helper.rb')
      ]
    end

    it 'removes duplicated paths' do
      paths = [
        'lib/guard/rubocop.rb',
        'spec/spec_helper.rb',
        'lib/guard/../guard/rubocop.rb'
      ]
      guard.clean_paths(paths).should == [
        File.expand_path('lib/guard/rubocop.rb'),
        File.expand_path('spec/spec_helper.rb')
      ]
    end

    it 'removes paths which are included in another path' do
      paths = [
        'lib/guard/rubocop.rb',
        'spec/spec_helper.rb',
        'spec'
      ]
      guard.clean_paths(paths).should == [
        File.expand_path('lib/guard/rubocop.rb'),
        File.expand_path('spec')
      ]
    end
  end

end
