class Schedules::Weekly < Schedule

  include Schedules::Interval
  include Schedules::DayOfWeek

  def initialize(attrs = {})
    args = attrs.slice :hour, :start_date, :time_zone, :interval, :day
    super(args)
  end

  def defaults
    super.merge :day => :FRI
  end

  def rrule
    super.merge :freq => 'weekly', :byday => day.to_s[0..2]
  end

  def local_occurrence?(t)
    super and t.wday == day_index
  end

  def recurrence
    'weekly'
  end

  protected

  def day=(value)
    @day = Schedule.coerce_day(value)
  end

  def to_s_base
    day_name = Date::DAYNAMES[day_index]
    if interval == 1
      day_name.pluralize
    elsif interval == 2
      "Every other #{day_name}"
    else
      "Every #{interval.ordinalize} #{day_name}"
    end
  end

end
