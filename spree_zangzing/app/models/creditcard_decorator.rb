Creditcard.class_eval do
   belongs_to :user
   belongs_to :payment_method

   include ActiveMerchant::Billing::CreditCardMethods

   before_validation :set_type

  private
  def set_type
    self.cc_type ||= Creditcard.type?( number )
  end

  # Saftey check to make sure we're not accidentally performing operations on a live gateway.
  # Ex. When testing in staging environment with a copy of production data.
  # modified to deal with our custom named environments
  # when 'production' will only work in photos_production
  # when 'dev/staging' will work unless photos_production
 def check_environment(gateway)
    return if gateway.environment == Rails.env
    if gateway.environment.blank? && Rails.env != "photos_production"
      return
    end
    message = I18n.t(:gateway_config_unavailable) + " - #{Rails.env}"
    raise Spree::GatewayError.new(message)
  end
end