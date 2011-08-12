CheckoutController.class_eval do

  before_filter :update_address_id, :only =>[:update]

  private
  def before_ship_address
    #new or edit existing order ship address yet.
    @order.ship_address = Address.default
    @order.ship_address.user = current_user
  end

  def before_bill_address
      #new or edit existing order ship address yet.
      @order.bill_address = Address.default
      @order.bill_address.user = current_user
    end


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

