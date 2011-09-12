CheckoutController.class_eval do

   before_filter :update_address_id, :only =>[:update]

   skip_before_filter :load_order, :only => [:registration, :guest_checkout]
   before_filter :check_registration, :except => [:registration, :guest_checkout]

   layout 'checkout'

   # Displays the store's "Login or Guest checkout" screen
   def registration
     #If the order started checkout as guest or if a user is logged in then continue
     redirect_to checkout_path and return if current_user || current_order.guest_checkout?
     @order = current_order
     redirect_to cart_path and return unless @order and @order.checkout_allowed?
     @user_session = UserSession.new(:email=> params[:email])
   end

   # When a guest proceeds with guest checkout
   def guest_checkout
      redirect_to checkout_path and return if current_user || current_order.guest_checkout?
      
     if current_order.enable_guest_checkout
       redirect_to checkout_path
     else
       redirect_to checkout_registration_url
     end
   end

   private
   # Introduces a registration step whenever the +registration_step+ preference is true.
   def check_registration
     return if  current_user || current_order.guest_checkout?
     store_location
     redirect_to checkout_registration_path 
   end

   # Overrides the equivalent method defined in spree_core. This variation of the method will ensure that users
   # are redirected to the tokenized order url unless authenticated as a registered user.
   def completion_route
     return order_path(@order) if current_user
     token_order_path(@order, @order.token)
   end

  def before_cart
    if  current_user || current_order.guest_checkout?
      if @order.next
        redirect_to checkout_state_path(@order.state)
      end
    else
      store_location
      redirect_to checkout_registration_path
    end
  end

  def before_ship_address
    #new or edit existing order ship address view.
    if current_user
      @order.ship_address ||= Address.default
      @order.ship_address.user = current_user
    else
      @order.ship_address ||= Address.default
    end
  end

  #executed before displaying the payment view
  def before_payment
    #remove any payments if you are updatind
    current_order.payments.destroy_all if request.put?
    if current_user
      @order.bill_address ||= Address.default
      @order.bill_address.user = current_user
    else
      @order.bill_address ||= Address.default
    end
  end

   # Executed after order is complete
   # Make the last used addresses, the user's default addresses
   # clone the used addresses and leave the non-user-associated addresses as part of the order
   # this prevents the user from editing addresses from a completed order
   def after_complete
     #remove the order from the session
     session[:order_id] = nil

     if current_user
       # If a user is looged in, save  addresses and creditcard as default
       # Backup order addresses with addresses that cannot be modified by user.
       # creditcards are non editable just erasable.
       #(no need to do this for guests)
       original_ship = @order.ship_address
       original_bill = @order.bill_address

       new_ship = Address.create( original_ship.attributes.except("id", "user_id", "updated_at", "created_at"))
       @order.ship_address_id = new_ship.id
       if original_ship.id == original_bill.id
         @order.bill_address_id = new_ship.id
       else
         if original_ship.same_as?( original_bill )
           @order.bill_address.id = new_ship.id
         else
           @order.bill_address = Address.create( original_bill.attributes.except("id", "user_id", "updated_at", "created_at"))
         end
       end
       @order.save

       # new creditcards should be saved in the user's wallet
       if @order.payment.source.user.nil?
         @order.payment.source.update_attributes!(
             :user_id => current_user.id
         )
       end

       #make addresses, creditcard user's default
       @order.user.update_attributes!(
           :bill_address_id => original_bill.id,
           :ship_address_id => original_ship.id,
           :creditcard_id   => @order.payment.source.id
       )
     end
   end

   # When the user clicks on an address from the addressbook, the order gets updated with
   # the appropriate address id.
   def update_address_id
     if params[:order]
       if params[:order][:ship_address_id]

         ship_address_id = params[:order][:ship_address_id]
         params[:order].delete :ship_address_id

         unless ship_address_id.blank?
           address = Address.find_by_id( ship_address_id )
           if address
             @order.ship_address = address
             params[:order].delete :ship_address_attributes
           end
           return true
         end
       end
       if params[:order][:bill_address_id]

         bill_address_id = params[:order][:bill_address_id]
         params[:order].delete :bill_address_id

         unless bill_address_id.blank?
           bill_address = Address.find_by_id( bill_address_id )
           if bill_address
             @order.bill_address = bill_address
             params[:order].delete :bill_address_attributes
           end
           return true
         end
       end
       true
     end
   end

   def object_params
     # For payment step, filter order parameters to produce the expected nested attributes for a single payment and its source, discarding attributes for payment methods other than the one selected
     if @order.payment?
       if params[:order][:creditcard_id]
         creditcard = Creditcard.find( params[:order][:creditcard_id] )
         #The payment method needs id and amount (set below) and payment method id, source_id and source_type
         params[:order][:payments_attributes].first[:payment_method_id] = creditcard.payment_method_id
         params[:order][:payments_attributes].first[:source_id] = creditcard.id
         params[:order][:payments_attributes].first[:source_type] = creditcard.class.name
         
         #clear creditcard id from order
         params[:order].delete( :creditcard_id )
         #delete all other credit card attributes to prevent validation errors
         params.delete(:payment_source) if params[:payment_source]
       end
       if params[:payment_source].present? && source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]
         params[:order][:payments_attributes].first[:source_attributes] = source_params
       end
       if (params[:order][:payments_attributes])
         params[:order][:payments_attributes].first[:amount] = @order.total
       end

     end
     params[:order]
   end

end

