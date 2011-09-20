module OrderNotifier
  extend ActiveSupport::Concern

  included do
    helper "spree/base"
  end

  module InstanceMethods
    def order_confirmed(order_id, template_id = nil)
      @order = Order.find(order_id)
      @user      = @order.user
      if @user
        @recipient = @order.user
      else
        @recipient = @order.email
      end
      @order_status_link = token_order_url(@order, @order.token)
      create_message(  __method__, template_id, @recipient, (@user ? { :user_id => @user.id } : nil ) )
    end


    def order_cancelled( order_id, template_id = nil )
      @order = Order.find(order_id)
      @user      = @order.user
      if @user
        @recipient = @order.user
      else
        @recipient = @order.email
      end
      create_message(  __method__, template_id, @recipient, (@user ? { :user_id => @user.id } : nil ) )
    end

    def order_shipped(shipment_id, template_id = nil)
      @shipment  = Shipment.find(shipment_id)
      @order     = @shipment.order
      @user      = @order.user
      if @user
        @recipient = @order.user
      else
        @recipient = @order.email
      end
      create_message(  __method__, template_id, @recipient, (@user ? { :user_id => @user.id } : nil ) )
    end
  end
end
