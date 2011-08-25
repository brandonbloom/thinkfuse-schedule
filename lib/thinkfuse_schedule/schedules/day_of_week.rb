module ThinkfuseSchedule::Schedule::DayOfWeek

  def self.included(base)
    base.class_eval do

      attr_reader :day

      validates_inclusion_of :day, :in => ThinkfuseSchedule::Schedule::DAYS

    end
  end

  def serialized_properties
    super + %w(day)
  end

  def ==(other)
    super and day == other.day
  end

  def day=(value)
    @day = ThinkfuseSchedule::Schedule.coerce_day(value)
  end

  def day_index
    ThinkfuseSchedule::Schedule.day_index(day)
  end

end
