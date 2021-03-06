CheckoutController.class_eval do


   before_filter :update_address_id, :only =>[:update]

   skip_before_filter :load_order, :only => [:registration, :guest_checkout]
   before_filter :check_registration, :except => [:registration, :guest_checkout]

   layout 'checkout'

   helper 'photo', 'products'


   # update is where the top level state transitions take place
   @@original_update ||= instance_method('update')
   def update
     # call with an empty context so we can collect and cache shipping info
     #Order.call_with_thread_options({}) do
     #  @@original_update.bind(self).call
     #end

     previous_total = @order.total
     changed = false
     err_code = nil
     Order.call_with_thread_options({ :prevent_update => true, :no_shipping_calc => true, :skip_tax => true }) do
       changed = @order.update_attributes(object_params)
     end

     if changed
       Order.call_with_thread_options({ :no_shipping_calc => false }) do
         @order.update!
       end

       Order.call_with_thread_options({ :prevent_update => true, :no_shipping_calc => true, :skip_tax => true }) do
         # if we are about to move to complete and charge the user make sure that the totals have not changed
         # this could happen if they updated quantities in another window
         if @order.state == 'confirm'
           if previous_total.round(2) != @order.total.round(2)
             err_code = :amounts_in_cart_changed
           end
         end
         if err_code.nil?
           if @order.next
             state_callback(:after)
           else
             err_code = :payment_processing_failed
           end
         end
       end

       if err_code == :amounts_in_cart_changed
         flash[:error] = I18n.t(err_code)
         flash[:payment] = 'The amounts in your cart have changed. )'+\
                                       ' Your order has been re-calculated.)'+\
                                       ' You can now place your order. '
         respond_with(@order) { |format| format.html { render :edit } }
         return
       elsif err_code
          flash[:error] = I18n.t(err_code)
          respond_with(@order, :location => checkout_state_path(@order.state))
          return
       end
       if @order.state == "complete" || @order.completed?
         flash[:notice] = I18n.t(:order_processed_successfully)
         flash[:commerce_tracking] = "nothing special"
         respond_with(@order, :location => completion_route)
       else
         respond_with(@order, :location => checkout_state_path(@order.state))
       end
     else
       respond_with(@order) { |format| format.html { render :edit } }
     end
   end

   # update is where the top level state transitions take place
   @@original_load_order ||= instance_method('load_order')
   def load_order
     # call with an empty context so we can collect and cache shipping info
     Order.call_with_thread_options({:prevent_update => true, :no_shipping_calc => true}) do
       @@original_load_order.bind(self).call
     end
   end

   def edit
     # call with an empty context so we can collect and cache shipping info
     Order.call_with_thread_options({}) do
       respond_with(@order) { |format| format.html { render :edit } }
     end
   end

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
    # current_order.payments.destroy_all if request.put?
    if current_user
      @order.bill_address ||= Address.default
      @order.bill_address.user = current_user
    else
      @order.bill_address ||= Address.default
    end
  end

   # executed when the user places the order
   # verifies that all the photos still exist
   # otherwise it warns the user that a photo has
   # been deleted and recalculates the order
   def before_confirm
     if !@order.all_photos_valid?
       if @order.line_items.count > 0
        flash.now[:error]="Please Review Your Order"
        flash.now[:payment]='A photo in your order was deleted while you were checking out. )'+\
                                      ' The item has been removed and your order re-calculated.)'+\
                                      ' You can now place your order. '
          respond_with(@order) { |format| format.html { render :edit } } and return
       else
         flash[:error]="Please Select More Photos"
         flash[:payment]='The photo in your order was deleted while you were checking out. )'+\
                                      ' The line item has been removed and your cart is now empty'
         redirect_to cart_url
       end
     end
   end


   # Executed after order is complete
   # Make the last used addresses, the user's default addresses
   # clone the used addresses and leave the non-user-associated addresses as part of the order
   # this prevents the user from editing addresses from a completed order
   def after_complete
     #remove the order from the session
     session[:order_id] = nil

     #add the order access token to the session so user can see thank you window
     #and order status, all through the orders controller.
     session[:access_token] ||= @order.token

     # trigger the photo copy and preparation, this is done here because normal state machine transitions
     # happen in a transaction and could allow resque work to begin too soon.  See comment in order_decorator.rb
     @order.prepare!

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

       # [:order][:ship_address_id] was inserted by the address book
       # it will be blank if no address from the book was selected
       # it will have the id if an address from the book was selected
       
       if params[:order][:ship_address_id]
         ship_address_id = params[:order][:ship_address_id]
         params[:order].delete :ship_address_id

        if !ship_address_id.blank?
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

         if !bill_address_id.blank?
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
     # For payment step, filter order parameters to produce the expected nested attributes
     # for a single payment and its source, discarding attributes for payment methods
     # other than the one selected
     if @order.payment?
       if params[:order][:creditcard_id]
         #The user did not type a new creditcard, she used the checkboxes
         if @order.payment && @order.payment.source && @order.payment.source.id.to_s == params[:order][:creditcard_id]
           # The selected checkbox/creditcard did NOT CHANGE don't change payment
           # delete all payment attributes to prevent payment from changing
           params[:order].delete( :payments_attributes )
         else
           # The selected creditcard changed delete current payments and set
           # params to create a new payemtn using the selected creditcard
           @order.payments.destroy_all
           creditcard = Creditcard.find( params[:order][:creditcard_id] )
           #The payment method needs id and amount (set below) and payment method id, source_id and source_type
           params[:order][:payments_attributes].first[:payment_method_id] = creditcard.payment_method_id
           params[:order][:payments_attributes].first[:source_id] = creditcard.id
           params[:order][:payments_attributes].first[:source_type] = creditcard.class.name
           params[:order][:payments_attributes].first[:amount] = @order.total
         end
         #clear creditcard id from order
         params[:order].delete( :creditcard_id )
         #delete all other empty credit card attributes to prevent validation errors
         params.delete(:payment_source) if params[:payment_source]
       else
          #the user typed a new creditcard, delete existing payments and setup a new one with the new crdit card
          @order.payments.destroy_all
          if params[:payment_source].present? && source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]
            params[:order][:payments_attributes].first[:source_attributes] = source_params
            params[:order][:payments_attributes].first[:amount] = @order.total
         end
       end
     end
     params[:order]
   end

  def completion_route

  end

# Overrides the equivalent method defined in spree_core. This variation of the method will ensure that users
   # are redirected to the tokenized order url unless authenticated as a registered user.
   def completion_route
    thankyou_order_url(@order)
   end

  def rescue_from_spree_gateway_error( exception )
      flash[:error] = t('spree_gateway_error_flash_for_checkout')
      flash[:payment] = exception.message
      render :edit
  end


end