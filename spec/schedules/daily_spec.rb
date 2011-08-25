require 'spec_helper'

describe Schedules::Daily do

  describe '#days' do

    it 'is validated' do
      Schedules::Daily.new(:days => []).should be_invalid
      Schedules::Daily.new(:days => [:FOO]).should be_invalid
    end

    it 'ignores duplicates' do
      Schedules::Daily.new(:days => [:MON, :MON]).days.should == [:MON]
    end

    it 'logically sorts days' do
      Schedules::Daily.new(:days => [:WED, :TUE]).days.should == [:TUE, :WED]
    end

    it 'ignores blank days (eases form handling)' do
      schedule = Schedules::Daily.new(:days => ['', :MON, ''])
      schedule.days.should == [:MON]
    end

  end

  describe '#==' do
    subject { Schedules::Daily.new(:days => [:TUE, :THU]) }
    it { should == Schedules::Daily.new(:days => [:TUE, :THU]) }
    it { should_not == Schedules::Daily.new(:days => [:MON, :FRI]) }
  end

  describe '#occurrences' do

    it 'finds next scheduled daily occurrences' do
      schedule = Schedules::Daily.new(
        :days => [:WED, :FRI], :hour => 6,
        :start_date => Date.new(2010, 10, 18))
      schedule.occurrences(:count => 4).should ==
        [Time.utc(2010, 10, 20, 6, 0), Time.utc(2010, 10, 22, 6, 0),
         Time.utc(2010, 10, 27, 6, 0), Time.utc(2010, 10, 29, 6, 0)]
    end

  end

  describe '#days_to_s' do

    it 'returns a list of day names' do
      schedule = Schedules::Daily.new(:days => [:MON, :WED, :FRI])
      schedule.days_to_s.should == 'Mondays, Wednesdays, and Fridays'
    end

    it 'special cases everyday' do
      days = Schedule::DAYS
      Schedules::Daily.new(:days => days).days_to_s.should == 'Everyday'
    end

    it 'special cases weekdays' do
      days = Schedule::WEEKDAYS
      Schedules::Daily.new(:days => days).days_to_s.should == 'Weekdays'
    end

  end

end
