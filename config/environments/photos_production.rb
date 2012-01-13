require 'cache_wrapper'

Server::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  ZZ::ZZA.default_zza_id = "photos/svr"

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

  # use syslogger
  app_tag = ZangZingConfig.running_as_resque? ? "rails/prod/rqphotos" : "rails/prod/photos"
  config.logger = Syslogger.new(app_tag)
  config.colorize_logging = false

  #config.log_level = :info
  #todo: go back to info this after memcached tested
  config.log_level = :debug

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = false
  config.action_view.debug_rjs                         = false
  config.action_controller.perform_caching             = true

# Keep rails in single threaded mode since we not utilized for our app server configurations
#    # Enable threaded mode
#  config.threadsafe!

  # override location of temp directory for our rails app
  ENV['TMPDIR'] = '/data/tmp'

  # set up location of file upload directory
  # this should be on EBS backed storage for production
  config.photo_upload_dir = '/data/tmp/photo_uploads'

  # set this in the environment you want to allow benchmark testing
  config.bench_test_allowed = false

  # set up to use memcached
  CacheWrapper.initialize_cache(:mem_cache_store, config, {:timeout => 1.5})

  # mail logger is too verbose, shut it off
  config.action_mailer.logger = nil

  ActionController::Base.asset_host = "%d.assets.photos.zangzing.com"

end
