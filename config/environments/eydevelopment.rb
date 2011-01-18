Server::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

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

  # set this in the environment you want to allow benchmark testing
  config.bench_test_allowed = false

  ActionController::Base.cache_store = :memory_store
end
