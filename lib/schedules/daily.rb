class Schedules::Daily < Schedule
  attr_reader :days

  validates_length_of :days, :message => 'Select at least one day',
                      :minimum => 1, :maximum => 7
  validate :validate_days

  def initialize(attrs = {})
    super attrs.slice(:hour, :start_date, :time_zone, :days)
  end

  def defaults
    super.merge :days => WEEKDAYS
  end

  def serialized_properties
    super + %w(days)
  end

  def ==(other)
    super and days == other.days
  end

  def recurrence
    'daily'
  end

  def rrule
    { :freq => 'weekly',
      :byday => days.map { |dow| dow.to_s[0..2] } }
  end

  def local_occurrence?(t)
    super and day_indices.include?(t.wday)
  end

  def days_to_s
    if days == DAYS
      'Everyday'
    elsif days == WEEKDAYS
      'Weekdays'
    else
      day_indices.map { |dow| Date::DAYNAMES[dow].pluralize }.to_sentence
    end
  end

  protected

  def days=(value)
    if value.blank?
      @days = []
    else
      @days = value.map { |dow| Schedule.coerce_day(dow) }
      @days.compact!
      @days.uniq!
      @days = @days.sort_by do |dow|
        Schedule.day_index(dow)
      end
    end
  end

  def day_indices
    days.map { |dow| Schedule.day_index(dow) }
  end

  alias to_s_base days_to_s

  def validate_days
    days.each do |day|
      unless Schedule::DAYS.include? day
        errors.add :days, "Unknown day :#{day}"
      end
    end
  end
end
