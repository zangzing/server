Server::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  ZZ::ZZA.default_zza_id = "staging.photos/svr"

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

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

  # override location of temp directory on EY servers
  ENV['TMPDIR'] = '/mnt/tmp'

  # set up location of file upload directory
  # this should be on EBS backed storage for production
  config.photo_upload_dir = '/data/tmp/photo_uploads'

  # set this in the environment you want to allow benchmark testing
  config.bench_test_allowed = true

  # use memcached
  config.cache_store = :mem_cache_store, MemcachedConfig.server_list

  # mail logger is too verbose, shut it off
  config.action_mailer.logger = nil

end