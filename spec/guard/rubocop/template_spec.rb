require 'guard/compat/test/template'

require 'guard/rubocop'

RSpec.describe Guard::RuboCop do
  describe 'template' do
    subject { Guard::Compat::Test::Template.new(described_class) }

    it 'matches Ruby files' do
      expect(subject.changed('lib/foo.rb')).to eq(%w(lib/foo.rb))
    end

    it 'matches .rubocop.yml files' do
      expect(subject.changed('.rubocop.yml')).to eq(%w(.))
      expect(subject.changed('foo/.rubocop.yml')).to eq(%w(foo))
    end
  end
end
