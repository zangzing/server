#
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class UserSession < Authlogic::Session::Base
  # allowing both cookie based and http basic auth together causes
  # Authlogic to screw up the cookie based auth on Rails 3
  allow_http_basic_auth      false

  remember_me                true
  remember_me_for            3.months
  last_request_at_threshold  1.minute  #how often to save last_request_at
  find_by_login_method :find_by_email_or_username # authenticate using email or username on login
  generalize_credentials_error_messages "Your login information is invalid"
  params_key :zzapi_key
  single_access_allowed_request_types :all
end