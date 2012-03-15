# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'spec/factories.rb'
require 'spec/controller_spec_helper.rb'
require "test_utils"

# set this to true if you want transactional fixtures, false if you want real transactions
use_transactional_fixtures = true
require 'after_commit_with_transactional_fixtures' if use_transactional_fixtures

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# flush the redis db used for testing
flush_redis_test_db

# set up the top level resque loopback filter by default, loopback is off
# for specific tests that need it they should use resque_loopback with
# the appropriate filters
filter = FilterHelper.new(:only => [])
ZZ::Async::Base.loopback_filter = filter

# auto_liking flag tells the User class if it should
# add greg, joseph, mauricio, jeremy, phil, etc as users
# that a new user likes.  For testing we don't generally
# want that behavior so we turn it off
User.auto_liking = false

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = use_transactional_fixtures
end


# these methods from from http://stackoverflow.com/questions/1025594/how-can-i-use-mock-models-in-authlogic-controller-specs

def current_user(stubs = {})
  @current_user ||= mock_model(User, stubs)
end

def user_session(stubs = {}, user_stubs = {})
  @current_user_session ||= mock_model(UserSession, {:user => current_user(user_stubs)}.merge(stubs))
end

def login(session_stubs = {}, user_stubs = {})
  UserSession.stub!(:find).and_return(user_session(session_stubs, user_stubs))
end

def logout
  @user_session = nil
end

def spec_dir
  File.expand_path('.', File.dirname(__FILE__))
end

# use the handy zz_api login method, works
# for web stuff also
# returns user_id
def zz_login(username, password)
  zz_logout
  body = zz_api_body({ :email => username, :password => password })
  path = build_full_path(zz_api_create_or_login_path, true)
  post path, body, zz_api_headers
  response.status.should eql(200)
  login_info = JSON.parse(response.body).recursively_symbolize_keys!
  user_id = login_info[:user_id]
end

def zz_logout
  zz_api_post zz_api_logout_path, nil, 200
end
