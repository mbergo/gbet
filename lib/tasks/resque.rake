require 'resque/tasks'
require 'resque_scheduler/tasks'

task "resque:scheduler_setup" => :environment
task "resque:setup" => :environment
