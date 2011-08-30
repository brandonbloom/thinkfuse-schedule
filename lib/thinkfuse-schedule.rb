require "thinkfuse-schedule/version"

require 'active_support/all'
require 'active_model'

# Define this here so all classes in ./schedules can have Schedules::<klass>
module Schedules
end

require 'schedule'
require 'schedules/daily'
require 'schedules/day_of_week'
require 'schedules/interval'
require 'schedules/weekly'
require 'schedules/monthly'
require 'schedules/monthly_by_day'
require 'schedules/monthly_by_week'
