# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "thinkfuse-schedule/version"

Gem::Specification.new do |s|
  s.name        = "thinkfuse-schedule"
  s.version     = ThinkfuseSchedule::VERSION
  s.authors     = ["Mark Golazeski"]
  s.email       = ["mark@thinkfuse.com"]
  s.homepage    = ""
  s.summary     = %q{Handle recurrent times based off a scheduel}
  s.description = %q{These are helpers designed to work with getting occurences based on a specified schedule. For example, figuring out the date of the next occurnece of an event that is scheduled for the 3rd Saturday of every 5th month.}

  s.rubyforge_project = "thinkfuse-schedule"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_runtime_dependency 'activemodel'
  s.add_runtime_dependency 'tzinfo'
  s.add_runtime_dependency 'ri_cal', '>= 0.5.1'
end
