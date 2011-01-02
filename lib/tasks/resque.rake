require "require_all"

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
   #put all resque worker configuration parameters here
end