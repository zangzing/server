class EzPrintController < Spree::BaseController

  def valid_events
    @@valid_events ||= Set.new(['Accepted', 'AssetsCollected', 'InProduction', 'Canceled', 'Shipment', 'CompleteShipment', 'Complete'])
  end

  def event_handler
    begin
      result = success_result # assume success

      orders = params['OrderEventNotification']['Order']
      orders = [orders] unless orders.is_a?(Array)

      orders.each do |order|
        order_id = order['id']
        # use the ezp_ref_num to find original request to ezprints - maybe order id is sufficient...
        ezp_ref_num = order['EZPReferenceNumber']
        spree_order = {}  #todo wire this up to actual orders

        # if matches one of our valid event types, call the method in this class
        order.each_pair do |key, value|
          if valid_events.include?(key)
            # underscore it and call method
            meth_name = key.underscore.to_sym
            self.send(meth_name, spree_order, value)
          end
        end
      end

    rescue Exception => ex
      result = failed_result(ex.message)
    end

    render :layout => false, :text => result, :content_type => 'text/xml'
  end

  # build the standard result just once
  def success_result
    @@success_xml ||= lambda {
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.OrderEventNotificationReceived({ :Result => "Success"})
      xml.target!
    }.call
  end

  def failed_result(msg)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.error({ :result => "failed", :msg => msg})
    xml.target!
  end

  # event handler methods
  def complete_shipment(order, details)
    puts "Complete shipment called"
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
) | curl -X POST -H 'Content-type: text/xml' -d @- http://localhost/store/integration/ezprint/events
SAMPLE_REQUEST
