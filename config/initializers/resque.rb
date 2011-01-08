#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
#   From suggestions found in https://github.com/defunkt/resque/blob/master/README.markdown

require 'resque/server'
require 'resque-retry'
require 'resque-retry/server'


if defined?(Rails.root) and File.exists?("#{Rails.root}/config/resque.yml")

  resque_config =   YAML::load_file("#{Rails.root}/config/resque.yml")
  Resque.redis = resque_config[Rails.env]
else
     abort %{ZangZing config/resque.yml file not found. UNABLE TO INITIALIZE QUEUEING SYSTEM!}
end


# HTTP Auth For Resque Console
if Server::Application.config.http_auth_credentials
  Resque::Server.use Rack::Auth::Basic do |username, password|
   username == Server::Application.config.http_auth_credentials[:login] && 
   password == Server::Application.config.http_auth_credentials[:password]
  end
end

msg = "=> Resque options loaded. redis host is: "+  resque_config[Rails.env]
Rails.logger.info msg
puts msg