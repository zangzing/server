source :gemcutter
#source 'http://gems.github.com'

# bundler requires these gems in all environments
gem "bundler","1.0.3"
gem "rails", "2.3.5"
gem "mysql"
gem 'authlogic',     '2.1.5'
gem 'usesguid',      :git => 'git://github.com/zangzing/usesguid.git'
gem 'usesguid_migrations'

gem 'oauth',         '0.4.1'
gem 'oauth-plugin',  '0.3.14'

gem 'paperclip',     '2.3.1.1'
gem 'aws-s3',        '>= 0.6.2', :require => 'aws/s3' # S3

gem 'resque'                                          # Queuing
gem 'SystemTimer'                                     # For Random numbers (resque uuid)

gem 'actionmailer'
gem 'will_paginate', '2.3.12'                         # Pagination

gem 'gdata',         '1.1.1'  						  # Google Data 
gem 'twitter_oauth'   		                          # Twitter 
gem 'hyper-graph',   '0.3.1', :require=>'hyper_graph' # Facebook
gem 'flickraw',      '0.8.2'                          # Flickr
gem 'vpim'                                            # VCard creator
gem 'rpm_contrib'                                     # For New Relic Performance Instrumentation
gem 'faker'                                           # To load sample data

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
