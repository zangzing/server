#
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class UserSession < Authlogic::Session::Base
  # allowing both cookie based and http basic auth together causes
  # Authlogic to screw up the cookie based auth on Rails 3
  allow_http_basic_auth false
# NOTE: following commented out temporarily - we may need it
# for creating a new account - revist once port to latest code
# GWS - 12/6/2010
#  find_by_login_method :find_by_email_or_username
end