# Settings specified here will take precedence over those in config/environment.rb

 config.gem "sqlite3-ruby", :lib => "sqlite3"

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
                  :enable_starttls_auto => true,
                  :address => 'smtp.gmail.com',
                  :port => 587,
                  :authentication => :plain,
                  :domain => 'gmail.com',
                  :user_name => 'dev.zangzing@gmail.com',
                  :password => 'share1001photos'
}


#paperclip will look for imagemagick here
Paperclip.options[:command_path] = ENV['IMAGEMAGICK_PATH']
Paperclip.options[:log] = true
Paperclip.options[:log_command] = true

APPLICATION_HOST = 'localhost:3000'