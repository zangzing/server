Server::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  ZZ::ZZA.default_zza_id = "dev.photos/svr"

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.

  # define USE_CLASS_CACHE in your environment if you want to override the default of false
  class_cache = ENV["USE_CLASS_CACHE"].nil? ? false : true
  config.cache_classes = class_cache

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_view.debug_rjs                         = true
  config.action_controller.perform_caching             = true

  # Don't care if the notifier can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => 'mail.authsmtp.com',
    :port => 26,
    :authentication => :plain,
    :domain => 'zangzing.com',
    :user_name => 'ac51517',
    :password => 'sfmvqvm4ehbrgw'
  }

  # set this in the environment you want to allow benchmark testing
  config.bench_test_allowed = true


##  ActionController::Base.cache_store = :memory_store
## TESTING USE MEMCACHED
##TODO remove and uncomment above line
  # use memcached
  path = config.paths.log.to_a.first
  config.logger = ActiveSupport::BufferedLogger.new(path)
  opts = {}
  opts[:logger] = config.logger
  opts[:timeout] = 1.5
  config.cache_store = :mem_cache_store, MemcachedConfig.server_list, opts

  # mail logger is too verbose, shut it off
  config.action_mailer.logger = nil
end
