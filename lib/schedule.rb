require 'ri_cal'


class Schedule

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serializers::JSON

  self.include_root_in_json = false

  DAYS = Date::ABBR_DAYNAMES.map { |d| d.upcase.to_sym }
  WEEKDAYS = DAYS[1..-2]

  attr_reader :start_date, :hour, :time_zone, :time_zone_name

  validate :validate_start_date, :validate_time_zone
  validates_numericality_of :hour, :only_integer => true,
                            :greater_than_or_equal_to => 0,
                            :less_than_or_equal_to => 23

  def self.load(string)
    if string.blank?
      nil
    elsif string.starts_with? '--- !ruby/object:'
      YAML.load(string)
    else
      load_from_cron(string)
    end
  end

  def self.load_from_cron(cron)
    parts = cron.split
    dom = parts[3]
    dow = parts[5]
    h = { :hour => parts[2].to_i,
          :time_zone => (cron =~ /\|/ ? cron.split('|')[1].strip : 'UTC') }
    if dom.to_i != 0
      Schedules::MonthlyByDay.new(h.merge(:day => dom.to_i))
    elsif dow[0..1] =~ /\d/
      Schedules::MonthlyByWeek.new(h.merge(
        :day => dow[0..1].to_i,
        :week => (dow[1..2] == 'L' ?  -1 : dow[2..3].to_i - 1)
      ))
    else
      days = dow.split(',').map{ |d| d.to_sym }
      if days.length == 1
        Schedules::Weekly.new(h.merge(:day => days.first))
      else
        Schedules::Daily.new(h.merge(:days => days))
      end
    end
  end

  DEFAULT_TIME_ZONE = ActiveSupport::TimeZone.new('UTC')

  def defaults
    # +start_date+ depends on +time_zone+, so set it manually in +initialize+.
    { :time_zone => DEFAULT_TIME_ZONE, :hour => 17 }
  end

  def initialize(attrs = {})
    attrs = attrs.symbolize_keys
    attrs.reverse_merge! defaults
    attrs.each_pair do |key, value|
      send "#{key}=", value
    end
    self.start_date ||= (time_zone.is_a?(ActiveSupport::TimeZone) ?
                         time_zone.today : DEFAULT_TIME_ZONE.today)
  end

  def serialized_properties
    %w(recurrence start_date hour time_zone_name)
  end

  def to_yaml_properties
    serialized_properties.map { |prop| "@#{prop}" }
  end

  def serializable_hash(options = {})
    h = {}
    serialized_properties.each do |prop|
      h[prop] = send(prop)
    end
    h
  end

  def ==(other)
    to_json == other.to_json
  end

  def rrule
    {}
  end

  def self.day_index(abbr)
    Date::ABBR_DAYNAMES.index(abbr.to_s.capitalize)
  end

  def hour_to_s
    if hour == 0
      'Midnight'
    elsif hour == 12
      'Noon'
    elsif hour < 12
      "#{ hour } am"
    else
      "#{ hour - 12 } pm"
    end
  end

  def to_s(include_zone = :auto)
    if include_zone == :auto
      include_zone = (Time.zone != time_zone)
    end
    base = "#{to_s_base} at #{hour_to_s}"
    if include_zone
      "#{base} #{time_zone.tzinfo.current_period.abbreviation}"
    else
      base
    end
  end

  def persisted?
    false
  end

  def start_time
    time_zone.local(start_date.year, start_date.month, start_date.day, hour, 0)
  end

  def to_ri_cal
    RiCal.Calendar do |calendar|
      calendar.event do |event|
        event.dtstart = start_time
        event.rrule = rrule
        #TODO: Use an exclusion rule instead of the #occurrence? trick.
        # This is so that the iCal output matches the #occurrences.
      end
    end
  end

  def occurrence?(t)
    local_occurrence?(t.in_time_zone(time_zone))
  end

  def local_occurrence?(t)
    time_zone == t.time_zone and
      time_zone.local(t.year, t.month, t.day, t.hour) == t
  end

  def occurrences(options = {})
    # The iCal spec forces the start date to be included as an occurrence,
    # so as a workaround, we request an additional occurrence and skip the
    # first occurrence if it doesn't match the recurrence rules.
    raise ':count option expected' unless options[:count]
    options[:count] += 1
    arr = to_ri_cal.events.first.occurrences(options)
    tz = options.delete(:time_zone) || time_zone
    arr.map! { |occurrence| occurrence.dtstart.in_time_zone(tz) }
    if occurrence?(arr.first)
      arr[0..-2]
    else
      arr[1..-1]
    end
  end

  def next(after = nil)
    return nil if invalid?
    if after.nil?
      starting = time_zone.now
    elsif after.is_a? ActiveSupport::TimeWithZone and after.time_zone.present?
      starting = after + 1.second
    else
      raise ArgumentError, 'Expected ActiveSupport::TimeWithZone'
    end
    occurrence = occurrences(:time_zone => starting.time_zone,
                             :starting => starting,
                             :count => 1).first
  end

  def time_zone
    if @time_zone
      @time_zone
    elsif @time_zone_name.is_a? String and @time_zone_name.present?
      ActiveSupport::TimeZone.new(@time_zone_name) || @time_zone_name
    else
      @time_zone_name
    end
  end

  protected

  def hour=(value)
    @hour = Integer(value)
  rescue
    @hour = value
  end

  def start_date=(value)
    case value
    when Date
      @start_date = value
    when String
      begin
        #TODO: What about different date formats?
        @start_date = Date.parse(value)
      rescue
        @start_date = value # Fail validation.
      else
        # Convert to full years.
        if @start_date.year < 100
          # OMG year 3000 bug! :-)
          @start_date = Date.new(@start_date.year + 2000,
                                 @start_date.month, @start_date.day)
        end
      end
    end
  end

  def time_zone=(value)
    if value.is_a? String
      @time_zone_name = value
    else
      @time_zone = value
      @time_zone_name = value.name
    end
  end

  def validate_time_zone
    unless time_zone.is_a? ActiveSupport::TimeZone
      errors.add :time_zone, "Unknown time_zone: #{time_zone}"
    end
  end

  def validate_start_date
    unless start_date.is_a? Date
      errors.add :start_date, 'Invalid start date specified'
    end
  end

  def self.coerce_day(day_of_week)
    if day_of_week.blank?
      nil
    elsif day_of_week.to_s.to_i == 0
      day_of_week.to_sym
    else
      begin
        DAYS[day_of_week.to_s.to_i - 1]
      rescue
        day_of_week
      end
    end
  end

  def self.from_hash(params)
    # Rewrite time_zone_name into a valid time_zone to ensure time_zone set.
    if params['time_zone_name']
      params['time_zone'] = ActiveSupport::TimeZone.new(params['time_zone_name'])
    end

    case params['recurrence']
    when 'none'
      return nil
    when 'daily'
      schedule = Schedules::Daily.new(params)
    when 'weekly'
      schedule = Schedules::Weekly.new(params)
    when 'monthly'
      case params['monthly_by']
      when 'day'
        schedule = Schedules::MonthlyByDay.new(params)
      when 'week'
        schedule = Schedules::MonthlyByWeek.new(params)
      else
        raise 'No monthly repeat selected'
      end
    end

    raise "Schedule not valid: #{schedule.errors}" if schedule.invalid?

    schedule
  end

  def self.coerce(from)
    case from
    when nil
      nil
    when Schedule
      from
    when Hash
      self.from_hash(from)
    when String
      self.load(from)
    else
      raise "Unable to coerce #{from.class} to Schedule"
    end
  end

end

