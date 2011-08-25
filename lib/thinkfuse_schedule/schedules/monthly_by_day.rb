class ThinkfuseSchedule::Schedule::MonthlyByDay < ThinkfuseSchedule::Schedule::Monthly

  attr_reader :day

  validates_numericality_of :day, :only_integer => true,
                            :greater_than_or_equal_to => 1,
                            :less_than_or_equal_to => 31

  def defaults
    super.merge :day => 1
  end

  def serialized_properties
    super + %w(day)
  end

  def ==(other)
    super and day == other.day
  end

  def rrule
    if day <= 28
      # Must specify a list of monthdays to work around this bug:
      # http://rick_denatale.lighthouseapp.com/projects/30941/tickets/30
      super.merge :bymonthday => [day, day]
    else
      # Clamp to the last day of the month.
      super.merge :bymonthday => (28..day).to_a, :bysetpos => -1
    end
  end

  def local_occurrence?(t)
    super and t.day == day
  end

  protected

  def day=(value)
    @day = Integer(value)
  rescue
    @day = value
  end

  def to_s_base
    "#{day.ordinalize} day #{interval_s}"
  end

end

