class EzPrintController < Spree::BaseController

  def valid_events
    @@valid_events ||= Set.new(['Accepted', 'AssetsCollected', 'InProduction', 'Canceled', 'Shipment', 'CompleteShipment', 'Complete'])
  end

  def event_handler
    begin
      #todo following code is for debugging only while we hook into ezprints
      in_data = request.raw_post
      Rails.logger.info(in_data.to_s)

      result = success_result # assume success

      # see if we got an error notification
      check_order_failed

      orders = params['OrderEventNotification']['Order']
      orders = [orders] unless orders.is_a?(Array)

      orders.each do |order|
        order_id = order['Id']
        # use the ezp_ref_num to find original request to ezprints - maybe order id is sufficient...
        ezp_ref_num = order['EZPReferenceNumber']
        spree_order = Order.find_by_ezp_reference_id(ezp_ref_num) || Order.find_by_number(order_id)
#        spree_order = {}  #todo wire this up to actual orders
        next if spree_order.nil?

        # if matches one of our valid event types, call the method in this class
        order.each_pair do |key, value|
          if valid_events.include?(key)
            # underscore it and call method
            meth_name = key.underscore.to_sym
            self.send(meth_name, spree_order, value)
            Rails.logger.info("Incoming EZPrints request was processed successfully: EZPrints Ref Number: #{ezp_ref_num} - Order Number #{spree_order.number}")
          end
        end
      end

    rescue Exception => ex
      Rails.logger.error("Failed to process incoming EZPrints notification: #{ex.message}")
      result = failed_result(ex.message)
    end

    render :layout => false, :text => result, :content_type => 'text/xml'
  end

  # build the standard result just once
  def success_result
    @@success_xml ||= lambda {
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.OrderEventNotificationReceived({ :result => "Success", :msg => 'Success'})
      xml.target!
    }.call
  end

  # build a failed reply - note we still
  # include the Success word which tells ezprints
  # to stop trying to notify us
  def failed_result(msg)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.OrderEventNotificationReceived({ :result => "Success", :msg => msg})
    xml.target!
  end

  # event handler methods
  def accepted(order, details)
    puts "accepted called"
  end

  def assets_collected(order, details)
    puts "assets_collected called"
  end

  def in_production(order, details)
    puts "in_production called"
  end

  def canceled(order, details)
    puts "canceled called"
  end

  def shipment(order, details)
    puts "shipment called"
  end

  def complete_shipment(order, details)
    puts "Complete shipment called"
  end

  def complete(order, details)
    puts "complete called"
  end

  private

  # checks to see if this is an order failed message
  # and if so, update the state and raise an error
  def check_order_failed
    order_failed = params['orderfailed']
    return if order_failed.nil?

    # yes, order failed, get info and raise exception
    ezp_ref_num = order_failed['referencenumber']
    ezp_error_message = order_failed['message']
    spree_order = Order.find_by_ezp_reference_id(ezp_ref_num)
    order_number = "order not found"
    unless spree_order.nil?
      order_number = spree_order.number
      spree_order.ezp_error_message = ezp_error_message
      spree_order.save!
      #todo: Advance the state to error
    end
    raise "Incoming order failed, EZPrints Ref Number: #{ezp_ref_num} - Order number: #{order_number} - Error: #{ezp_error_message}"
  end
end



# sample request:
<<SAMPLE_REQUEST
(cat <<'EOP'
<?xml version="1.0" encoding="UTF-8"?>
<OrderEventNotification Id="1275335">
   <Order Id="12345" EZPReferenceNumber="00417-200807251106-97968">
      <CompleteShipment DateTime="2008-07-27T12:36:04.0000000" Carrier="USPS" Service="First Class"
            DeliveryMethod="USPS First Class" TrackingNumber="">
         <Item Id="313358638" Sku="10020" PartnerSku="10020" Quantity="1" />
      </CompleteShipment>
   </Order>
   <Order Id="12345" EZPReferenceNumber="00521-200807251106-97968">
      <CompleteShipment DateTime="2008-07-27T14:56:04.0000000" Carrier="USPS" Service="Economy"
            DeliveryMethod="USPS Economy" TrackingNumber="">
         <Item Id="313358623" Sku="10022" PartnerSku="10022" Quantity="2" />
      </CompleteShipment>
   </Order>
   <Order Id="12345" EZPReferenceNumber="00506-200807251106-97968">
      <CompleteShipment DateTime="2008-07-27T18:17:04.0000000" Carrier="USPS" Service="First Class"
            DeliveryMethod="USPS First Class" TrackingNumber="">
         <Item Id="313358678" Sku="40026" PartnerSku="40026" Quantity="1" />
      </CompleteShipment>
   </Order>
</OrderEventNotification>
EOP
) | curl -X POST -H 'Content-type: text/xml' -d @- http://ezprints.integration.zangzing.com/store/integration/ezprint/events

# failure case
(cat <<'EOP'
<?xml version="1.0" encoding="UTF-8"?>
<orderfailed AffiliateID="940">
   <ordernumber>718362</ordernumber>
   <referencenumber>00123-200708031121-62724</referencenumber>
   <message>4002 Error: Type mismatch</message>
</orderfailed>
EOP
) | curl -X POST -H 'Content-type: text/xml' --dump-header headers.txt -d @- http://ezprints.integration.zangzing.com/store/integration/ezprint/events

SAMPLE_REQUEST
