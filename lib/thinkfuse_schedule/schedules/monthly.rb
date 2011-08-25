class ThinkfuseSchedule::Schedule::Monthly < ThinkfuseSchedule::Schedule
  include ThinkfuseSchedule

  include Schedule::Interval

  REQUEST_PARAMS = [:hour, :start_date, :time_zone, :interval, :day]

  def initialize(attrs = {})
    super attrs.slice(*REQUEST_PARAMS)
  end

  def rrule
    super.merge :freq => 'monthly'
  end

  def recurrence
    'monthly'
  end

  protected

  def interval_s
    if interval == 1
      'of each month'
    elsif interval == 2
      'of every other month'
    else
      "of every #{interval.ordinalize} month"
    end
  end

end
