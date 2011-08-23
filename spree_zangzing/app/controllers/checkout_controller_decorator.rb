CheckoutController.class_eval do

   before_filter :update_address_id, :only =>[:update]

   before_filter :check_registration, :except => [:registration, :guest_checkout]

   def registration
     @user_session = UserSession.new(:email=> params[:email])
     Spree::BaseController.asset_path = "%s"
     render :layout => false
     Spree::BaseController.asset_path = "/store%s"
   end

   def guest_checkout
     if current_order.enable_guest_checkout
       redirect_to checkout_path
     else
      redirect_to checkout_registration_url
     end
   end

   private
   # Introduces a registration step whenever the +registration_step+ preference is true.
   def check_registration
     return if  current_user || current_order.email
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
    if current_user
      @order.ship_address = Address.default
      @order.ship_address.user = current_user
    else
      @order.ship_address ||= Address.default
    end
  end

  #executed before displaying the bill address view
  def before_bill_address
      #new or edit existing order ship address yet.
    if current_user
      @order.bill_address = Address.default
      @order.bill_address.user = current_user
    else
      @order.bill_address ||= Address.default
    end
  end

  #executed before displaying the payment view
  def before_payment
      #remove any payments if you are updatind
      current_order.payments.destroy_all if request.put?
  end

  # Executed after order is complete
  # Make the last used addresses, the user's default addresses
  # clone the used addresses and leave the non-user-associated addresses as part of the order
  # this prevents the user from editing addresses from a completed order
   def after_complete
     # If a user is looged in, save as default and backup order addresses (no need to do this for guests)
     if current_user
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

       #make addresses, user's default
       if @order.bill_address_id && @order.ship_address_id
         @order.user.update_attributes!(
             :bill_address_id => original_bill.id,
             :ship_address_id => original_ship.id )
       end
     end
     session[:order_id] = nil
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
        params[:order].delete :ship_address_attributes
      elsif params[:order][:bill_address_id]
        address = Address.find_by_id( params[:order][:bill_address_id] )
        if address
          @order.bill_address = address
        end
        params[:order].delete :bill_address_id
        params[:order].delete :bill_address_attributes
      end
    end
    true
  end



end

