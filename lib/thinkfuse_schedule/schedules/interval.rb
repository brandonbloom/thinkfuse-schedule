module ThinkfuseSchedule::Schedule::Interval

  def self.included(base)
    base.class_eval do

      attr_reader :interval
      protected :interval=

      validates_numericality_of :interval, :only_integer => true,
                                :greater_than => 0

    end
  end

  def defaults
    super.merge :interval => 1
  end

  def serialized_properties
    super + %w(interval)
  end

  def ==(other)
    super and interval == other.interval
  end

  def rrule
    if interval == 1
      super
    else
      super.merge :interval => interval
    end
  end

  # local_occurrence? is intentionally not overridden, as it is only needed
  # to check the *first* occurrence for working around ical dtstart behavior.

  def interval=(value)
    @interval = value.to_i
  end

end

