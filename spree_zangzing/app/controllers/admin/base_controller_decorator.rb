Admin::BaseController.class_eval do
 before_filter :require_user, :require_admin

end
