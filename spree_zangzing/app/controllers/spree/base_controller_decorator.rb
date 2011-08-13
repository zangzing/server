#require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/zz/auth')
#require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/zz/zza')
#require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/zz/zza_controller')
#require File.expand_path(File.dirname(__FILE__) + '/../../../../app/helpers/pretty_url_helper')


Spree::BaseController.class_eval do
  include ZZ::Auth
  include ZZ::ZZAController
  include PrettyUrlHelper

  # This method is originally defined in lib/spree/current_order.rb
  # This should be overridden by an auth-related extension which would then have the
  # opportunity to associate the new order with the # current user before saving.
  def before_save_new_order
    @current_order.user  = current_user if current_user
  end
end