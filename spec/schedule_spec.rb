require 'spec_helper'

describe Schedule do

  describe '#start_date' do

    it 'accepts a date' do
      date = Date.new(2010, 5, 5)
      schedule = Schedule.new(:start_date => date)
      schedule.start_date.should be_a Date
      schedule.start_date.should == date
      schedule.should be_valid
    end

    it 'parses a string' do
      schedule = Schedule.new(:start_date => '2009-08-09')
      schedule.start_date.should == Date.new(2009, 8, 9)
      schedule.should be_valid
    end

    it 'passes through invalid strings' do
      date_s = '88/9/2009'
      schedule = Schedule.new(:start_date => date_s)
      schedule.start_date.should == date_s
      schedule.should be_invalid
    end

    it 'converts strings with two digit years to four digit years' do
      schedule = Schedule.new(:start_date => '34-1-2')
      schedule.start_date.should == Date.new(2034, 1, 2)
      schedule.should be_valid
    end

  end

  describe '#hour' do

    it 'must be an hour of the day, starting with 0 as midnight' do
      Schedule.new(:hour => -1).should be_invalid
      Schedule.new(:hour => 1).should be_valid
      Schedule.new(:hour => 9).hour.should == 9
      Schedule.new(:hour => 23).should be_valid
      Schedule.new(:hour => 24).should be_invalid
    end

    it 'accept string strings' do
      schedule = Schedule.new(:hour => '7')
      schedule.hour.should == 7
      schedule.should be_valid
      schedule = Schedule.new(:hour => 'blargh')
      schedule.hour.should == 'blargh'
      schedule.should be_invalid
    end

  end

  describe '#time_zone' do

    it 'accepts time zone objects' do
      tz = ActiveSupport::TimeZone.new('US/Pacific')
      schedule = Schedule.new(:time_zone => tz)
      schedule.time_zone.should == tz
      schedule.should be_valid
    end

    it 'accepts strings' do
      tz_name = 'US/Eastern'
      schedule = Schedule.new(:time_zone => tz_name)
      schedule.time_zone.should == ActiveSupport::TimeZone.new(tz_name)
      schedule.should be_valid
    end

    it 'rejects invalid names' do
      tz_name = 'NOT A ZONE'
      schedule = Schedule.new(:time_zone => tz_name)
      schedule.time_zone.should == tz_name
      schedule.should be_invalid
    end

  end

  describe '.load' do

    it 'returns nil for blank arguments' do
      Schedule.load(nil).should == nil
      Schedule.load('').should == nil
    end

    it 'loads YAML'

    it 'parses daily cron expressions' do
      schedule = Schedule.load('0 0 14 ? * TUE,THU')
      schedule.should be_a Schedules::Daily
      schedule.hour.should == 14
      schedule.days.should == [:TUE, :THU]
      schedule.time_zone.should == ActiveSupport::TimeZone.new('UTC')
    end

    it 'parses weekly cron expressions' do
      schedule = Schedule.load('0 0 8 ? * TUE')
      schedule.should be_a Schedules::Weekly
      schedule.hour.should == 8
      schedule.day.should == :TUE
      schedule.to_s.should == 'Tuesdays at 8 am'
    end

    it 'parses cron expressions with appended time zones' do
      cron = '0 0 14 ? * TUE,THU | Mountain Time (US & Canada)'
      schedule = Schedule.load(cron)
      schedule.should be_a Schedules::Daily
      schedule.hour.should == 14
      schedule.days.should == [:TUE, :THU]
      schedule.time_zone.name.should == 'Mountain Time (US & Canada)'
    end

    it 'parses monthly by day of week cron expressions' do
      schedule = Schedule.load('0 0 17 ? * 7#2')
      schedule.should be_a Schedules::Monthly
      schedule.hour.should == 17
      schedule.day.should == :SAT
      schedule.week.should == 1 # converted to 0 base
      schedule.to_s.should == '2nd Saturday of each month at 5 pm'
      schedule = Schedule.load('0 0 17 ? * 1L')
      schedule.to_s.should == 'Last Sunday of each month at 5 pm'
      schedule.week.should == -1
    end

    it 'parses monthly by day of month cron expressions' do
      schedule = Schedule.load('0 0 12 5 * ?')
      schedule.should be_a Schedules::Monthly
      schedule.hour.should == 12
      schedule.day.should == 5
      schedule.to_s.should == '5th day of each month at Noon'
    end

  end

  describe '#initialize' do

    it 'sets attributes'
    it 'utilizes defaults'
    it 'symbolizes keys'

  end

  describe '#hour_to_s' do

    it 'returns a 12 hour clock string' do
      Schedule.new(:hour => 10).hour_to_s.should == '10 am'
      Schedule.new(:hour => 14).hour_to_s.should == '2 pm'
    end

    it 'special cases midnight' do
      Schedule.new(:hour => 0).hour_to_s.should == 'Midnight'
    end

    it 'special cases noon' do
      Schedule.new(:hour => 12).hour_to_s.should == 'Noon'
    end

  end

  pending 'calculates occurrences in its own time zone' do
    west = ActiveSupport::TimeZone.new('America/Los_Angeles')
    east = ActiveSupport::TimeZone.new('America/New_York')
    # Weekly west coast schedule with east coast queries.
    weekly = Schedule.new(:kind => :weekly,
                          :hour => 17,
                          :day => :FRI,
                          :time_zone => west,
                          :start_date => Date.new(2010, 11, 1))
    n = weekly.next(east.local(2010, 12, 23, 3, 35))
    n.should == east.local(2010, 12, 24, 20, 0)
    # Monthly east coast schedule with UTC queries verified on west coast.
    monthly = Schedule.new(:kind => :monthly,
                           :repeat_by => :day_of_week,
                           :day => :SAT,
                           :week => 0,
                           :hour => 1,
                           :start_date => Date.new(2010, 12, 1),
                           :time_zone => east)
    n = monthly.next(Time.utc(2011, 1, 4, 2, 2).in_time_zone(UTC))
    n.in_time_zone(west).should == west.local(2011, 2, 4, 22, 0)
  end

end
