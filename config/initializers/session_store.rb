# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_zangzing_session',
  :secret      => '76b3ddca2c952ddcf8300bbb537a4fe0052c9b57a59397db6ac67706317a4812fd5aa8c990e58467ae8496d5b0c15de71c890d52b91dbaa77341072f72dd2cc2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
