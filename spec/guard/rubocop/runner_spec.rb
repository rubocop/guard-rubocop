# coding: utf-8

require 'spec_helper.rb'

describe Guard::Rubocop::Runner do
  subject(:runner) { Guard::Rubocop::Runner.new(options) }
  let(:options) { {} }

  describe '#run' do
    subject { super().run(paths) }
    let(:paths) { ['spec/spec_helper.rb'] }

    before do
      runner.stub(:system)
    end

    it 'executes rubocop' do
      runner.should_receive(:system) do |*args|
        args.first.should == 'rubocop'
      end
      runner.run
    end

    context 'when RuboCop exited with 0 status' do
      before do
        runner.stub(:system).and_return(true)
      end
      it { should be_true }
    end

    context 'when RuboCop exited with non 0 status' do
      before do
        runner.stub(:system).and_return(false)
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
          runner.stub(:system).and_return(true)
        end

        if expectations[:passed]
          include_examples 'notifies'
        else
          include_examples 'does not notify'
        end
      end

      context 'when failed' do
        before do
          runner.stub(:system).and_return(false)
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

  describe '#build_command' do
    let(:paths) { %w(file1.rb file2.rb) }

    it 'adds args for the default formatter for console' do
      runner.build_command(paths)[0..2].should == %w(rubocop --format progress)
    end

    it 'adds args for JSON formatter ' do
      runner.build_command(paths)[3..4].should == %w(--format json)
    end

    it 'adds args for output file path of JSON formatter ' do
      command = runner.build_command(paths)
      command[5].should == '--out'
      command[6].should_not be_empty
    end

    it 'adds the passed paths' do
      runner.build_command(paths)[7..-1].should == %w(file1.rb file2.rb)
    end
  end

  describe '#json_file_path' do
    it 'is not world readable' do
      File.world_readable?(runner.json_file_path).should be_false
    end
  end

  shared_context 'JSON file', :json_file do
    before do
      json = <<-END
        {
          "metadata": {
            "rubocop_version": "0.9.0",
            "ruby_engine": "ruby",
            "ruby_version": "2.0.0",
            "ruby_patchlevel": "195",
            "ruby_platform": "x86_64-darwin12.3.0"
          },
          "files": [{
              "path": "lib/foo.rb",
              "offences": []
            }, {
              "path": "lib/bar.rb",
              "offences": [{
                  "severity": "convention",
                  "message": "Line is too long. [81/79]",
                  "cop_name": "LineLength",
                  "location": {
                    "line": 546,
                    "column": 80
                  }
                }, {
                  "severity": "warning",
                  "message": "Unreachable code detected.",
                  "cop_name": "UnreachableCode",
                  "location": {
                    "line": 15,
                    "column": 9
                  }
                }
              ]
            }
          ],
          "summary": {
            "offence_count": 2,
            "target_file_count": 2,
            "inspected_file_count": 2
          }
        }
      END
      File.write(runner.json_file_path, json)
    end
  end

  describe '#result', :json_file do
    it 'parses JSON file' do
      runner.result[:summary][:offence_count].should == 2
    end
  end

  describe '#notify' do
    before do
      runner.stub(:result).and_return(
        {
          summary: {
            offence_count: 4,
            target_file_count: 3,
            inspected_file_count: 2
          }
        }
      )
    end

    it 'notifies summary' do
      Guard::Notifier.should_receive(:notify) do |message, options|
        message.should == '2 files inspected, 4 offences detected'
      end
      runner.notify(true)
    end

    it 'notifies with title "RuboCop results"' do
      Guard::Notifier.should_receive(:notify) do |message, options|
        options[:title].should == 'RuboCop results'
      end
      runner.notify(true)
    end

    context 'when passed' do
      it 'shows success image' do
        Guard::Notifier.should_receive(:notify) do |message, options|
          options[:image].should == :success
        end
        runner.notify(true)
      end
    end

    context 'when failed' do
      it 'shows failed image' do
        Guard::Notifier.should_receive(:notify) do |message, options|
          options[:image].should == :failed
        end
        runner.notify(false)
      end
    end
  end

  describe '#summary_text' do
    before do
      runner.stub(:result).and_return(
        {
          summary: {
            offence_count: offence_count,
            target_file_count: target_file_count,
            inspected_file_count: inspected_file_count
          }
        }
      )
    end

    subject(:summary_text) { runner.summary_text }

    let(:offence_count)        { 0 }
    let(:target_file_count)    { 0 }
    let(:inspected_file_count) { 0 }

    context 'when no files are inspected' do
      let(:inspected_file_count) { 0 }
      it 'includes "0 files"' do
        summary_text.should include '0 files'
      end
    end

    context 'when a file is inspected' do
      let(:inspected_file_count) { 1 }
      it 'includes "1 file"' do
        summary_text.should include '1 file'
      end
    end

    context 'when 2 files are inspected' do
      let(:inspected_file_count) { 2 }
      it 'includes "2 files"' do
        summary_text.should include '2 files'
      end
    end

    context 'when no offences are detected' do
      let(:offence_count) { 0 }
      it 'includes "no offences"' do
        summary_text.should include 'no offences'
      end
    end

    context 'when an offence is detected' do
      let(:offence_count) { 1 }
      it 'includes "1 offence"' do
        summary_text.should include '1 offence'
      end
    end

    context 'when 2 offences are detected' do
      let(:offence_count) { 2 }
      it 'includes "2 offences"' do
        summary_text.should include '2 offences'
      end
    end
  end

  describe '#failed_paths', :json_file do
    it 'returns file paths which have offences' do
      runner.failed_paths.should == ['lib/bar.rb']
    end
  end
end
