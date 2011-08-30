require 'rspec'
require 'ri_cal'
require 'thinkfuse-schedule'

# No current user to default time zone, so set to UTC here
Time.zone = ActiveSupport::TimeZone.new('UTC')

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
