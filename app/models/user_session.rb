#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class UserSession < Authlogic::Session::Base

  #UserSession.cookie_key = 'zangzing_user_session'

  find_by_login_method :find_by_email_or_username
end