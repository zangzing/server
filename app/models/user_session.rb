#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class UserSession < Authlogic::Session::Base

  find_by_login_method :find_by_email_or_username
end