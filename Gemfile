source :gemcutter
#source 'http://gems.github.com'

#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

# All Gems MUST have a version number (Avoid having to chase a bug caused by an updated gem)

# Bundler requires these gems in all environments (keep executables light by being frugal)

gem "bundler",              '1.0.3'
gem "rails",                '3.0.1'
gem "mysql",                '2.8.1' 
gem 'authlogic',            '2.1.5'
gem 'usesguid',             :git => 'git://github.com/zangzing/usesguid.git'
gem 'usesguid_migrations',  '1.0.3'

gem 'oauth',                '0.4.1'  
gem 'oauth-plugin',         '0.3.14'

gem 'paperclip',            '2.3.5'
gem 'aws-s3',               '>= 0.6.2', :require => 'aws/s3' # S3
gem 'resque',               '1.10.0'                         # Queuing
gem 'SystemTimer',          '1.2'                            # Interruptions based Timeout
gem 'will_paginate',        '3.0.pre'                        # Pagination

gem 'gdata',                '1.1.1'  					     # Google Data 
gem 'twitter_oauth',   		'0.4.3'                          # Twitter 
gem 'hyper-graph',          '0.3.1', :require=>'hyper_graph' # Facebook
gem 'flickraw',             '0.8.2'                          # Flickr
gem 'bitly',                '0.5.3'                          # Bitly duh?

gem 'vpim',                 '0.695'                          # VCard creator
gem 'rpm_contrib',          '1.0.13'                         # New Relic Perf Instrumentation
gem 'faker',                '0.3.1'                          # To load sample data

group :development do
  # bundler requires these gems in development

end

group :test do
  # bundler requires these gems while running tests
  gem 'webrat'
  gem 'rspec'  
  gem 'mechanize'
  gem 'launchy'
  gem 'rspec-rails', '>= 1.3.2' 
  gem 'factory_girl'
end

group :production do
  # bundler requires these gems for production
end
