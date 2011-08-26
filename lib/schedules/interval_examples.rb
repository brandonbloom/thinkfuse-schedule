require 'spec_helper'

shared_examples_for 'schedules with an interval' do

  describe '#interval' do

    it 'parses string values' do
      described_class.new(:interval => '2').interval.should == 2
    end

    it 'must be a positive integer' do
      described_class.new.should be_valid
      described_class.new(:interval => 5).should be_valid
      described_class.new(:interval => -1).should be_invalid
      described_class.new(:interval => 'blah').should be_invalid
      described_class.new(:interval => 0).should be_invalid
    end

  end

  describe '#==' do
    subject { described_class.new(:interval => 3) }
    it { should == described_class.new(:interval => 3) }
    it { should_not == described_class.new(:interval => 4) }
  end

  describe '#rrule' do

    it 'does not include a an interval option for interval == 1' do
      described_class.new(:interval => 1).rrule[:interval].should be_nil
    end

    it 'includes an interval option for interval != 1' do
      described_class.new(:interval => 3).rrule[:interval].should == 3
    end

  end

end

