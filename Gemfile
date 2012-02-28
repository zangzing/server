source :gemcutter
#source 'http://gems.github.com'

# bundler requires these gems in all environments -
gem "bundler", ">=1.0.14"
gem "rails", "3.0.9"
gem "unicorn"
gem "dynamic_form"
gem "mysql2",     "~> 0.2.7"
gem 'authlogic',     '3.0.0'
gem "friendly_id",   "3.2.1.1"                       #User-friendly links to albums and users' pages
gem 'uuidtools'
gem 'activerecord-import', '~>0.2'  # bulk database inserts
gem "json", ">= 1.6.3"

gem "require_all"                 # lets us pull in everything for our resque tasks

gem 'syslogger',     "1.2.6", :git => 'git://github.com/zangzing/syslogger.git'

gem 'oauth',         "0.4.5.pre2", :git => 'git://github.com/zangzing/oauth-ruby.git'
gem "oauth-plugin", "0.4.0.pre4"



gem 'faraday',      '0.5.4'
gem 'i18n'
gem 'aws-s3',       :require => 'aws/s3'
gem 'right_aws'
gem 'redis',        '~>2.1'
gem 'resque',       '1.9.10'                          # Async work jobs
gem 'resque-retry'
gem 'SystemTimer'                                     # For Random numbers (resque uuid)
gem 'will_paginate',        '3.0.pre2'                        # Pagination
gem 'gdata',         '1.1.1'  						  # Google Data
gem 'twitter_oauth'   		                          # Twitter 
gem 'hyper-graph',   '0.3.1', :require=>'hyper_graph' # Facebook
gem 'flickraw',      '0.8.2'                          # Flickr
gem 'bitly'                                           # Bitly duh?
gem 'gibbon',         '0.1.2'                          # MailChimp API
gem 'instagram'                                       # Instagram
gem 'dropbox'                                         # Dropbox
gem 'money'
gem 'addressable'                                     # Better URL parser
gem 'premailer'                                       # Used for CSS inlining in EmailTemplates

gem 'vpim'                                            # VCard creator
gem 'rpm_contrib'                                     # For New Relic Performance Instrumentation
gem 'faker'                                           # To load sample data
gem 'memcache-client'

gem "jammit"
gem "yui-compressor"
gem "closure-compiler"
gem "nokogiri"
gem "browser" 

group :development do
  # bundler requires these gems in development
  gem 'ruby-prof'
end

group :test do
  # bundler requires these gems while running tests
  gem 'webrat'
  gem 'rspec'  
  gem 'mechanize'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'selenium'
  gem 'selenium-client'
  gem 'zip'
  gem 'pony'
end

group :production do
  # bundler requires these gems for production
end

group :deployment do
  gem 'less'
end

gem 'spree_core', :path => "./spree_core-0.60.1"
gem 'spree_dash', '0.60.1'
gem 'spree_promo', '0.60.1'
gem "spree_zangzing", :require => "spree_zangzing", :path => "./spree_zangzing"

