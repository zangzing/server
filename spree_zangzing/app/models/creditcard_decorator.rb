Creditcard.class_eval do
   belongs_to :user
   belongs_to :payment_method

   include ActiveMerchant::Billing::CreditCardMethods

   before_validation :set_type

  private
  def set_type
    self.cc_type ||= Creditcard.type?( number )
  end

end