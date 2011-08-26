class Schedules::Monthly < Schedule

  include Schedules::Interval

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

  def serialized_properties
    super + %w(monthly_by)
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
