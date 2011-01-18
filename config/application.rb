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

    # pull in all files within lib
    #GWS - pulling this out for now since it has conflicts in deployment EY
    #require_all 'lib'


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
    #GWS for testing sendgrid handler only - do not check in with this set to greg
    #config.album_email_host =  'greg-post.zangzing.com'
    config.album_email_host =  'sendgrid-post.zangzing.com'
    config.zangzing_version = '0.0.2'
    config.http_auth_credentials = YAML.load(File.read("#{Rails.root}/config/http_auth_creds.yml"))
  
  
    #This is actionmailer default config
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.default_url_options = {:host => config.application_host }
    config.action_mailer.sendmail_settings = {:arguments => '-i'} # workaround for sSMTP bug not accepting -t option

    config.active_support.deprecation = :log

    ActiveRecord::Base.guid_generator = :random

    # in rails 3 the default is to include the type of object as a
    # key in the output json.  we want the rails 2 behavior where
    # the key is not included 
    ActiveRecord::Base.include_root_in_json = false

    # Bitly API Setup
    Bitly.use_api_version_3
  end
end




