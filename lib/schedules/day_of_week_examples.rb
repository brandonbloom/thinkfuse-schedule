require 'spec_helper'

shared_examples_for 'schedules with a day of week' do

  describe '#day' do

    it 'coerces to day of week symbols' do
      described_class.new(:day => :MON).should be_valid
      described_class.new(:day => :BLAH).should be_invalid
    end

    it 'accepts strings' do
      schedule = described_class.new(:day => 'TUE')
      schedule.day.should == :TUE
      schedule.should be_valid
    end

    it 'accepts day 1 based day indices' do
      schedule = described_class.new(:day => 3)
      schedule.day.should == :TUE
      schedule.should be_valid
    end

  end

end

