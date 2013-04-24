# coding: utf-8

require 'spec_helper.rb'
require 'term/ansicolor'

describe Guard::Rubocop::Runner, :silence_output do
  include CaptureHelper

  subject(:runner) { Guard::Rubocop::Runner.new(options) }
  let(:options) { {} }

  describe '#run' do
    subject { super().run(paths) }
    let(:paths) { ['spec/spec_helper.rb'] }

    before do
      runner.stub(:rubocop)
    end

    it 'executes rubocop' do
      runner.should_receive(:rubocop)
      runner.run
    end

    context 'when all files are passed' do
      before do
        runner.stub(:rubocop).and_return(0)
      end
      it { should be_true }
    end

    context 'when any file is failed' do
      before do
        runner.stub(:rubocop).and_return(1)
      end
      it { should be_false }
    end

    shared_examples 'notifies', :notifies do
      it 'notifies' do
        runner.should_receive(:notify)
        runner.run
      end
    end

    shared_examples 'does not notify', :does_not_notify do
      it 'does not notify' do
        runner.should_not_receive(:notify)
        runner.run
      end
    end

    shared_examples 'notification' do |expectations|
      context 'when passed' do
        before do
          runner.stub(:rubocop).and_return(0)
        end

        if expectations[:passed]
          include_examples 'notifies'
        else
          include_examples 'does not notify'
        end
      end

      context 'when failed' do
        before do
          runner.stub(:rubocop).and_return(1)
        end

        if expectations[:failed]
          include_examples 'notifies'
        else
          include_examples 'does not notify'
        end
      end
    end

    context 'when :notification option is true' do
      let(:options) { { notification: true } }
      include_examples 'notification', { passed: true, failed: true }
    end

    context 'when :notification option is :failed' do
      let(:options) { { notification: :failed } }
      include_examples 'notification', { passed: false, failed: true }
    end

    context 'when :notification option is false' do
      let(:options) { { notification: false } }
      include_examples 'notification', { passed: false, failed: false }
    end
  end

  describe '#rubocop' do
    let(:paths) { ['spec/spec_helper.rb'] }

    it 'runs rubocop command' do
      capture(:stdout) do
        runner.rubocop(paths)
      end.should include 'inspected'
    end

    it 'returns exit code and output' do
      exit_code, output = runner.rubocop(paths)
      exit_code.should == 0
      output.should include 'inspected'
    end
  end

  describe '#output' do
    subject { super().output }
    let(:paths) { ['spec/spec_helper.rb'] }

    context 'before running' do
      it { should be_nil }
    end

    context 'after running' do
      before do
        runner.stub(:notify)
      end

      it 'returns uncolored output of rubocop command' do
        captured_output = capture(:stdout) { runner.run(paths) }
        runner.output.should == Term::ANSIColor.uncolor(captured_output)
      end
    end
  end

  shared_context 'stubbed output', :stubbed_output do
    before do
      runner.stub(:output) do
<<OUTPUT
== /home/foo/guard-rubocop/lib/guard/rubocop.rb ==
C:  1: Missing encoding comment.
== /home/foo/guard-rubocop/spec/support/silence_output.rb ==
C:  3: Ruby 1.8 hash syntax detected

7 files inspected, 2 offences detected
OUTPUT
      end
    end
  end

  describe '#notify', :stubbed_output do
    it 'notifies summary' do
      Guard::Notifier.should_receive(:notify) do |message, options|
        message.should == '7 files inspected, 2 offences detected'
      end
      runner.notify
    end

    it 'notifies with title "RuboCop results"' do
      Guard::Notifier.should_receive(:notify) do |message, options|
        options[:title].should == 'RuboCop results'
      end
      runner.notify
    end

    context 'when passed' do
      before do
        runner.stub(:passed).and_return(true)
      end

      it 'shows success image' do
        Guard::Notifier.should_receive(:notify) do |message, options|
          options[:image].should == :success
        end
        runner.notify
      end
    end

    context 'when failed' do
      before do
        runner.stub(:passed).and_return(false)
      end

      it 'shows failed image' do
        Guard::Notifier.should_receive(:notify) do |message, options|
          options[:image].should == :failed
        end
        runner.notify
      end
    end
  end

  describe '#summary', :stubbed_output do
    subject { super().summary }

    it 'returns summary line of output' do
      should == '7 files inspected, 2 offences detected'
    end
  end

  describe '#failed_paths', :stubbed_output do
    subject { super().failed_paths }

    it 'returns failed file paths as array' do
      should == [
        '/home/foo/guard-rubocop/lib/guard/rubocop.rb',
        '/home/foo/guard-rubocop/spec/support/silence_output.rb'
      ]
    end
  end

end
