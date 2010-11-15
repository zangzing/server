#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#


require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)


module Server
  class Application < Rails::Application
  
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    config.time_zone = 'Tijuana'
    
    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password << :password_confirmation
    
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)
    
    # This allows for GUID use in primary keys 
    config.active_record.schema_format = :sql 
    ActiveRecord::Base.guid_generator = :mysql
  
  
    # ZangZing Server Defaul Configuration Values
    config.application_host =  'localhost:3000'
    config.album_email_host =  'sendgrid-post.zangzing.com'
    config.zangzing_version = '0.0.2'
    config.http_auth_credentials = YAML.load(File.read("#{Rails.root}/config/http_auth_creds.yml"))
  
  
    #This is actionmailer default config
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.default_url_options = {:host => config.application_host }

    config.active_support.deprecation = :log

    ActiveRecord::Base.guid_generator = :random
  end
end




