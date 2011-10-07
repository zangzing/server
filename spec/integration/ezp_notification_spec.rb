require 'spec_helper'

include PrettyUrlHelper

describe "EZPrints Notification Handler" do
  def affiliate_id
    940
  end

  def cancel_order_number
    'R564117518'
  end

  def cancel_order_id
    7
  end

  def cancel_ez_ref_num
    '00123-200708031121-55555'
  end

  def order_number
    'R464822726'
  end

  def order_id
    9
  end

  def ez_ref_num
    'ba6cfaa9-9d9b-4543-8b54-ef80022eca68'
  end

  def line_items
    [8,9]
  end

  def ez_path
    'http://http://ezprints.integration.zangzing.com/store/integration/ezprint/events'
  end

  def ez_headers
    {'HTTP_ACCEPT' => '*/*', 'CONTENT_TYPE' => 'text/xml'}
  end

  def order_state_should_match(order_id, expected, next_state = nil)
    order = Order.find(order_id)
    cur_state = order.state
    unless next_state.nil?
      order.state = new_state
      order.save
    end
    cur_state.should == expected
  end

  def reset_order_state(order_id, new_state)
    order = Order.find(order_id)
    order.state = new_state
    order.save
  end

  it "should handle failure notification" do

    body = <<-BLOCK
<?xml version="1.0" encoding="UTF-8"?>
<orderfailed AffiliateID="#{affiliate_id}">
 <ordernumber>#{order_number}</ordernumber>
 <referencenumber>#{ez_ref_num}</referencenumber>
 <message>4002 Error: Type mismatch</message>
</orderfailed>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Incoming order failed/).should_not == nil

    order_state_should_match(order_id, 'failed')
#    order_state_should_match(order_id, 'failed', 'preparing')
  end

  it "should handle Accepted and advance order state" do

    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{order_number}" EZPReferenceNumber="#{ez_ref_num}">
      <Accepted DateTime="2008-06-13T13:01:51.0000000" />
   </Order>
</OrderEventNotification>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order_state_should_match(order_id, 'accepted')
  end

  it "should handle Assets Collected and advance order state" do

    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{order_number}" EZPReferenceNumber="#{ez_ref_num}">
      <AssetsCollected DateTime="2008-06-13T13:01:51.0000000" />
   </Order>
</OrderEventNotification>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order_state_should_match(order_id, 'submitted')
  end

  it "should handle InProduction and advance order state" do

    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{order_number}" EZPReferenceNumber="#{ez_ref_num}">
      <InProduction DateTime="2008-06-13T13:01:51.0000000" />
   </Order>
</OrderEventNotification>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order_state_should_match(order_id, 'processing')
  end

  it "should handle CompleteShipment and advance order state" do

    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{order_number}" EZPReferenceNumber="#{ez_ref_num}">
      <CompleteShipment DateTime="2008-06-20T08:45:03.0000000" Carrier="FEDEX"
            Service="Second Business Day: FedEX 2 Day"
            DeliveryMethod="FedEx HOME DELIVERY" TrackingNumber="200326870226813">
         <Item Id="#{line_items[0]}" Sku="10040" PartnerSku="10040" Quantity="1" />
      </CompleteShipment>
      <CompleteShipment DateTime="2008-06-20T08:45:03.0000000" Carrier="USPS"
            Service="1st Class Mail"
            DeliveryMethod="USPS 1st Class Mail" TrackingNumber="">
         <Item Id="#{line_items[1]}" Sku="10040" PartnerSku="10040" Quantity="2" />
      </CompleteShipment>
   </Order>
</OrderEventNotification>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order_state_should_match(order_id, 'shipped')
  end


  it "should handle full Shipment in one message and advance order state" do

    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{order_number}" EZPReferenceNumber="#{ez_ref_num}">
      <Shipment DateTime="2008-06-20T08:45:03.0000000" Carrier="FEDEX"
            Service="Second Business Day: FedEX 2 Day"
            DeliveryMethod="FedEx HOME DELIVERY" TrackingNumber="200326870226813">
         <Item Id="#{line_items[0]}" Sku="10040" PartnerSku="10040" Quantity="1" />
         <Item Id="#{line_items[1]}" Sku="10040" PartnerSku="10040" Quantity="2" />
      </Shipment>
   </Order>
</OrderEventNotification>
    BLOCK

    order = Order.find(order_id)
    order.accept
    order.in_process

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order_state_should_match(order_id, 'shipped')
  end

  it "should handle Complete and advance order state" do

    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{order_number}" EZPReferenceNumber="#{ez_ref_num}">
      <Complete DateTime="2008-06-13T13:01:51.0000000" />
   </Order>
</OrderEventNotification>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order_state_should_match(order_id, 'shipped')
  end

  it "should handle full Shipment in parts and advance order state" do

    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{order_number}" EZPReferenceNumber="#{ez_ref_num}">
      <Shipment DateTime="2008-06-20T08:45:03.0000000" Carrier="FEDEX"
            Service="Second Business Day: FedEX 2 Day"
            DeliveryMethod="FedEx HOME DELIVERY" TrackingNumber="200326870226813">
         <Item Id="#{line_items[0]}" Sku="10040" PartnerSku="10040" Quantity="1" />
      </Shipment>
   </Order>
</OrderEventNotification>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order_state_should_match(order_id, 'submitted')


    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{order_number}" EZPReferenceNumber="#{ez_ref_num}">
      <Shipment DateTime="2008-06-20T08:45:03.0000000" Carrier="USPS"
            Service="1st Class Mail"
            DeliveryMethod="USPS 1st Class Mail" TrackingNumber="">
         <Item Id="#{line_items[1]}" Sku="10040" PartnerSku="10040" Quantity="2" />
      </Shipment>
   </Order>
</OrderEventNotification>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order_state_should_match(order_id, 'shipped')
  end

  it "should handle Canceled and advance order state" do

    body = <<-BLOCK
<OrderEventNotification Id="1176390">
   <Order Id="#{cancel_order_number}" EZPReferenceNumber="#{cancel_ez_ref_num}">
      <Canceled DateTime="2008-06-13T13:01:51.0000000" />
   </Order>
</OrderEventNotification>
    BLOCK

    post ez_path, body, ez_headers
    response.status.should eql(200)

    xml = Nokogiri::XML(response.body)
    msg = xml.at_xpath("/OrderEventNotificationReceived/@msg").content.to_s

    msg.match(/^Success/).should_not == nil

    order = Order.find(cancel_order_id)
    order_state_should_match(cancel_order_id, 'ezp_canceled')

  end


end