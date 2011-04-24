#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#


require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'active_record/connection_adapters/mysql2_adapter'
require 'config/initializers/zangzing_config'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Server
  class Application < Rails::Application

    # set the default primary key type to be a big int
    ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "BIGINT UNSIGNED DEFAULT NULL auto_increment PRIMARY KEY"

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

  
    # ZangZing Server Defaul Configuration Values
    #config.application_host =  'porch.rubyriders.com:3001'
    config.application_host =  'localhost:3000'

    # sendgrid email to album address
    config.album_email_host =  ZangZingConfig.config[:album_email_host]
    config.zangzing_version = '0.0.2'
    config.http_auth_credentials = YAML.load(File.read("#{Rails.root}/config/http_auth_creds.yml"))[Rails.env]
  
  
    #This is actionmailer default config
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.default_url_options = {:host => config.application_host }
    config.action_mailer.sendmail_settings = {:arguments => '-i'} # workaround for sSMTP bug not accepting -t option

    config.active_support.deprecation = :log

    # in rails 3 the default is to include the type of object as a
    # key in the output json.  we want the rails 2 behavior where
    # the key is not included 
    ActiveRecord::Base.include_root_in_json = false

    # turn off ip spoofing check so we work with proxies that are misconfigured such
    # as Southwest Airlines in flight internet
    config.action_controller.ip_spoofing_check = false

    # Bitly API Setup
    Bitly.use_api_version_3

  end
end




