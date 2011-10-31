unless defined? ZZ::ZZASender::ZZA_TEMP_DIR
  require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/zz/zza')
  require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/zz/zza_controller')
  require File.expand_path(File.dirname(__FILE__) + '/../../../../lib/zz/auth')
  require File.expand_path(File.dirname(__FILE__) + '/../../../../app/helpers/pretty_url_helper')
end


Spree::BaseController.class_eval do
  include ZZ::Auth
  include ZZ::ZZAController
  include PrettyUrlHelper
  include BuyHelper


  helper :tracking
  
  # This method is originally defined in lib/spree/current_order.rb
  # This should be overridden by an auth-related extension which would then have the
  # opportunity to associate the new order with the # current user before saving.
  def before_save_new_order
    @current_order.associate_user( current_user )
  end

  def after_save_new_order
    # make sure the user has permission to access the order (if they are a guest)
    return if current_user
    session[:access_token] = @current_order.token
  end

end