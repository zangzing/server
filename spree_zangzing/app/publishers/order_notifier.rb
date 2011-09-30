module OrderNotifier
  extend ActiveSupport::Concern

  included do
    helper "spree/base"
    helper :tracking
  end

  module InstanceMethods
    def order_confirmed(order_id, template_id = nil)
      @order = Order.find(order_id)
      @user = nil
      if @order.guest
        @recipient = @order.email
      else
        @user      = @order.user
        if @user
          @recipient = @order.user
        else
          @recipient = @order.email
        end
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

    #This is an internal message to create a Zendesk ticket,
    # this email is not part of the standard templating system
    def order_support_request( order, subject)
      @order = order
      if Rails.env.photos_production?
        full_subject = "[Store] Order #{@order.number} #{subject}"
      else
        full_subject = "[Store #{Rails.env}]  Order #{@order.number} #{subject}"
      end
      #create message
      mail( :to       => "help@zangzing.com",
            :from     => "ZangZing Store <store@zangzing.com>",
            :subject  => full_subject )

    end
  end
end
