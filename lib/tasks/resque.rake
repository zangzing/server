require "require_all"
require 'resque/tasks'
require 'resque_scheduler/tasks'
require 'zz/zza'
require 'config/initializers/zangzing_config'

task "resque:setup" => :environment do
  puts "resque:setup"

  if Rails.env == "development"
    puts "Not preloading in development environment"
  else
    puts "Pulling in all dependencies"
    require_all "app/models"
    require_all "app/helpers"
    require_all "lib"
    puts "Done pulling in dependencies"
  end

  # this is a hack to determine if we were called by the resque:scheduler rake task
  # since I'm not sure how I can determine my task if I am called by another
  ARGV.each do |arg|
    if arg == "resque:scheduler"
      # set up schedule for scheduler
      puts "Resque process for: " + arg
      Resque.schedule = ResqueScheduleConfig.config
      break
    end
  end

   #put all resque worker configuration parameters here

  # init ZZA with resque specific ids
  ZZ::ZZA.default_zza_id = ZangZingConfig.config[:resque_zza_id]

  ZangZingConfig.running_as_resque = true

end