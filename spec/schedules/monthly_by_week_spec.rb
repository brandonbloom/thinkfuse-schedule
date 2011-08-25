require 'spec_helper'
require 'schedules/interval_examples'
require 'schedules/day_of_week_examples'

describe ThinkfuseSchedule::Schedule::MonthlyByWeek do

  it_behaves_like 'schedules with an interval'
  it_behaves_like 'schedules with a day of week'

  describe '#week' do

    it 'may be a zero-based week of the month index' do
      Schedules::MonthlyByWeek.new(:week => 0).should be_valid
      Schedules::MonthlyByWeek.new(:week => 3).should be_invalid
      schedule = Schedules::MonthlyByWeek.new(:week => '2')
      schedule.week.should == 2
      schedule.should be_valid
      schedule = Schedules::MonthlyByWeek.new(:week => 'blah')
      schedule.should be_invalid
      schedule.week.should == 'blah'
    end

    it 'can represent "last week" as -1' do
      schedule = Schedules::MonthlyByWeek.new(:week => -1)
      schedule.week.should == -1
      schedule.should be_valid
      schedule = Schedules::MonthlyByWeek.new(:week => -2)
      schedule.week.should == -2
      schedule.should be_invalid
    end

  end

  describe '#==' do
    subject { Schedules::MonthlyByWeek.new(:week => 1, :day => :MON) }
    it { should == Schedules::MonthlyByWeek.new(:week => 1, :day => :MON) }
    it { should_not == Schedules::MonthlyByWeek.new(:week => 1, :day => :TUE) }
    it { should_not == Schedules::MonthlyByWeek.new(:week => 3, :day => :MON) }
  end

  describe '#occurrences' do

    it 'finds next scheduled monthly occurrences by day of week' do
      schedule = Schedules::MonthlyByWeek.new(
        :day => :MON, :week => 0, :hour => 17,
        :start_date => Date.new(2010, 12, 1))
      schedule.occurrences(:count => 2).should ==
        [Time.utc(2010, 12, 6, 17, 0), Time.utc(2011, 1, 3, 17, 0)]
    end

    it 'works for the last week of the month' do
      schedule = Schedules::MonthlyByWeek.new(
        :day => :FRI, :week => -1, :hour => 7,
        :start_date => Date.new(2011, 2, 7))
      schedule.occurrences(:count => 2).should ==
        [Time.utc(2011, 2, 25, 7, 0), Time.utc(2011, 3, 25, 7, 0)]
    end

    it 'respects the interval' do
      schedule = Schedules::MonthlyByWeek.new(
        :day => :FRI, :week => -1, :hour => 7, :interval => 3,
        :start_date => Date.new(2011, 2, 7))
      schedule.occurrences(:count => 2).should ==
        [Time.utc(2011, 2, 25, 7, 0), Time.utc(2011, 5, 27, 7, 0)]
    end

  end

  describe '#to_s' do

    def assert_to_s(week, day, interval, s)
      schedule = Schedules::MonthlyByWeek.new(
        :week => week, :day => day, :hour => 2, :interval => interval)
      schedule.to_s.should == "#{s} at 2 am"
    end

    it 'returns a description of the schedule' do
      assert_to_s(1, :WED, 1, '2nd Wednesday of each month')
      assert_to_s(-1, :TUE, 2, 'Last Tuesday of every other month')
      assert_to_s(0, :FRI, 3, '1st Friday of every 3rd month')
    end

  end

end
