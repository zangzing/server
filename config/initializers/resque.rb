#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
#   From suggestions found in https://github.com/defunkt/resque/blob/master/README.markdown

require 'resque/server'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]

#in routes.rb: mount the resque server at a specific route
#in routes.rb: mount Resque::Server.new, :at => "/resque"

# HTTP Auth For Resque Console
if Server::Application.config.http_auth_credentials
  Resque::Server.use Rack::Auth::Basic do |username, password|
   username == Server::Application.config.http_auth_credentials[:login] && 
   password == Server::Application.config.http_auth_credentials[:password]
  end
end

msg = "=> Resque options loaded. redis host is: "+  resque_config[rails_env]
Rails.logger.info msg
puts msg