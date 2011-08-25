require 'spec_helper'
require 'schedules/interval_examples'
require 'schedules/day_of_week_examples'

describe Schedules::Weekly do

  it_behaves_like 'schedules with an interval'
  it_behaves_like 'schedules with a day of week'

  describe '#==' do
    subject { Schedules::Weekly.new(:day => :MON) }
    it { should == Schedules::Weekly.new(:day => :MON) }
    it { should_not == Schedules::Weekly.new(:day => :TUE) }
    it { should_not == Schedules::Weekly.new(:day => :MON, :interval => 2) }
  end

  describe '#occurrences' do

    it 'finds next scheduled weekly occurrences' do
      schedule = Schedules::Weekly.new(
        :day => :FRI, :hour => 5, :start_date => Date.new(2011, 3, 24))
      schedule.occurrences(:count => 2).should ==
        [Time.utc(2011, 3, 25, 5), Time.utc(2011, 4, 1, 5)]
    end

    it 'respects the interval' do
      schedule = Schedules::Weekly.new(
        :day => :THU, :hour => 2, :interval => 2,
        :start_date => Date.new(2011, 3, 24))
      schedule.occurrences(:count => 2).should ==
        [Time.utc(2011, 3, 24, 2), Time.utc(2011, 4, 7, 2)]
    end

  end

end
