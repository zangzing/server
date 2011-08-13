CheckoutController.class_eval do

   before_filter :update_address_id, :only =>[:update]

   before_filter :check_registration, :except => [:registration, :update_registration]

   def registration
     Spree::BaseController.asset_path = "%s"
     render :layout => false
     Spree::BaseController.asset_path = "/store%s"
   end

   def update_registration
     # hack - temporarily change the state to something other than cart so we can validate the order email address
     current_order.state = "ship_address"
     if current_order.update_attributes(params[:order])
       redirect_to checkout_path
     else
       render 'registration'
     end
   end

   private
   # Introduces a registration step whenever the +registration_step+ preference is true.
   def check_registration
     return if current_user or current_order.email
     store_location
     redirect_to checkout_registration_path
   end

   # Overrides the equivalent method defined in spree_core. This variation of the method will ensure that users
   # are redirected to the tokenized order url unless authenticated as a registered user.
   def completion_route
     return order_path(@order) if current_user
     token_order_path(@order, @order.token)
   end

  #executed before displaying the ship address view
  def before_ship_address
    #new or edit existing order ship address view.
    @order.ship_address = Address.default
    @order.ship_address.user = current_user
  end

  #executed before displaying the bill address view
  def before_bill_address
      #new or edit existing order ship address yet.
      @order.bill_address = Address.default
      @order.bill_address.user = current_user
    end

  #executed before displaying the payment view
  def before_payment
    #remove any payments if you are updatind
    current_order.payments.destroy_all if request.put?

    #If there is no billing address create an empty one
    if @order.bill_address.nil?
      @order.bill_address = Address.default
      @order.bill_address.user = current_user
      @capture_bill_address = true
    end
  end

  # When the user clicks on an address from the addressbook, the order gets updated with
  # the appropriate address id.
  def update_address_id
    if params[:order]
      if params[:order][:ship_address_id]
        address = Address.find_by_id( params[:order][:ship_address_id] )
        if address
          @order.ship_address = address
        end
        params[:order].delete :ship_address_id
      elsif params[:order][:bill_address_id]
        address = Address.find_by_id( params[:order][:bill_address_id] )
        if address
          @order.bill_address = address
        end
        params[:order].delete :bill_address_id
      end
    end
    true
  end


end

