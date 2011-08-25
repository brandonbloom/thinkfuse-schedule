require 'spec_helper'
require 'schedules/interval_examples'

describe Schedules::MonthlyByDay do

  it_behaves_like 'schedules with an interval'

  describe '#day' do

    it 'must be a valid day of the month' do
      Schedules::MonthlyByDay.new(:day => 0).should be_invalid
      s = Schedules::MonthlyByDay.new(:day => 1)
      s.day.should == 1
      s.should be_valid
      s = Schedules::MonthlyByDay.new(:day => 31)
      s.day.should == 31
      s.should be_valid
      Schedules::MonthlyByDay.new(:day => 32).should be_invalid
    end

    it 'accepts strings' do
      s = Schedules::MonthlyByDay.new(:day => '5')
      s.day.should == 5
      s.should be_valid
    end

  end

  describe '#==' do
    subject { Schedules::MonthlyByDay.new(:day => 5) }
    it { should == Schedules::MonthlyByDay.new(:day => 5) }
    it { should_not == Schedules::MonthlyByDay.new(:day => 2) }
  end

  describe '#occurrences' do

    it 'finds next scheduled monthly occurrences by day of month' do
      schedule = Schedules::MonthlyByDay.new(
        :day => 6, :hour => 5, :start_date => Date.new(2010, 12, 4))
      schedule.occurrences(:count => 2).should ==
        [Time.utc(2010, 12, 6, 5, 0), Time.utc(2011, 1, 6, 5, 0)]
    end

    it 'clamps days at the end of the month' do
      schedule = Schedules::MonthlyByDay.new(
        :day => 30, :hour => 10, :start_date => Date.new(2011, 1, 8))
      schedule.occurrences(:count => 2).should ==
        [Time.utc(2011, 1, 30, 10, 0), Time.utc(2011, 2, 28, 10, 0)]
    end

    it 'respects the interval' do
      schedule = Schedules::MonthlyByDay.new(
        :day => 30, :hour => 10, :interval => 2,
        :start_date => Date.new(2011, 1, 8))
      schedule.occurrences(:count => 2).should ==
        [Time.utc(2011, 1, 30, 10, 0), Time.utc(2011, 3, 30, 10, 0)]
    end

  end

  describe '#to_s' do

    def assert_to_s(day, interval, s)
      schedule = Schedules::MonthlyByDay.new(
        :day => day, :interval => interval, :hour => 9)
      schedule.to_s.should == s
    end

    it 'returns a description of the schedule' do
      assert_to_s(8, 1, '8th day of each month at 9 am')
      assert_to_s(3, 2, '3rd day of every other month at 9 am')
      assert_to_s(2, 3, '2nd day of every 3rd month at 9 am')
    end

  end

end
