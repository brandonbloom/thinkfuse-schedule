class ThinkfuseSchedule::Schedule::MonthlyByWeek < ThinkfuseSchedule::Schedule::Monthly
  include ThinkfuseSchedule

  include Schedule::DayOfWeek

  attr_reader :week

  validates_inclusion_of :week, :in => -1..2

  def initialize(attrs = {})
    REQUEST_PARAMS.push(:week)
    super
  end

  def defaults
    super.merge :week => 0, :day => :MON
  end

  def serialized_properties
    super + %w(week)
  end

  def ==(other)
    super and week == other.week
  end

  def rrule
    super.merge :byday => "#{week >= 0 ? week + 1 : week}#{day.to_s[0..2]}"
  end

  def local_occurrence?(t)
    super and days_in_month(t.year, t.month)[week] == t.day
  end

  protected

  def week=(value)
    @week = Integer(value)
  rescue
    @week = value
  end

  def to_s_base
    occurrence = (week == -1 ?  'Last' : (week + 1).ordinalize)
    day_name = Date::DAYNAMES[Schedule.day_index(day)]
    "#{occurrence} " + "#{day_name} #{interval_s}"
  end

  def days_in_month(year, month)
    t = Date.new(year, month, 1)
    days = []
    while t.month == month
      if t.wday == day_index
        days << t.day
      end
      t += 1.day
    end
    days
  end

end
