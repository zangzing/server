require "require_all"
require 'resque/tasks'
require 'resque_scheduler/tasks'
require 'zz/zza'
require 'config/initializers/zangzing_config'

task "resque:setup" => :environment do
  # determine if should run forked or not - resque using the global $TESTING to indicate non forked
  # we might want to monkey patch to use another flag but this will do for now
  Server::Application.config.resque_run_forked ? $TESTING = false : $TESTING = true
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
   #put all resque worker configuration parameters here

  # init ZZA with resque specific ids
  ZZ::ZZA.default_zza_id = ZangZingConfig.config[:resque_zza_id]

end