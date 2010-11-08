#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
#   From suggestions found in https://github.com/defunkt/resque/blob/master/README.markdown

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]

msg = "=> Resque options loaded. redis host is: "+  resque_config[rails_env]
Rails.logger.info msg
puts msg