require 'braintree'

class Store::CreditcardsController < Store::BaseController

  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = "ppg8rg9ymsbzffzs"
  Braintree::Configuration.public_key =  "4942qbzqb4zkgjgj"
  Braintree::Configuration.private_key = "4t2vrzf7g53bzb8d"

  def new
    cust = customer
    @tr_data = Braintree::TransparentRedirect.create_credit_card_data(
      :redirect_url => "http://www.postbin.org/14g5cxx",
      :credit_card => {
        :customer_id => cust.id,
        :billing_address => {
              :country_code_alpha2 => "US"
            }
      }
    )
  end

  def create
    
  end


  def customer
    cust = nil
    begin
      cust = Braintree::Customer.find( current_user.id )
    rescue Braintree::NotFoundError
      cust = Braintree::Customer.create( :id => current_user.id )
    end
    cust
  end
  

end