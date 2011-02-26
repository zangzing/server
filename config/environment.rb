# Load the rails application
require File.expand_path('../application', __FILE__)

# We want ZZA to be available very early on so it
# can be used to report startup problems if we want
require 'zz/zza'

# Initialize the rails application
Server::Application.initialize!

