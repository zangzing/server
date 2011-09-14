require "rspec"
require 'nokogiri'
require "hash_converter"


describe "HashConverter" do
  before(:each) do
    test_str = <<-BLOCK
    <shippingOptions>
      <order orderid="R464822726">
        <option type="FC" price="1.75" shippingMethod="USFC" description="Domestic Economy to United States"/>
        <option type="PM" price="4.95" shippingMethod="USPM" description="Domestic Express to United States"/>
        <option type="SD" price="9.95" shippingMethod="USSD" description="Domestic Second Day to United States"/>
        <option type="ON" price="16.95" shippingMethod="OVNT" description="Domestic Next Day to United States"/>
      </order>
    </shippingOptions>
    BLOCK

    @xml = Nokogiri::XML(test_str)
  end

  it "should convert xml with separate attributes" do
    hash = HashConverter.from_xml(@xml, true)

    hash[:shippingOptions][:order][:attributes][:orderid].should == "R464822726"
  end

  it "should convert xml without separate attributes" do
    hash = HashConverter.from_xml(@xml, false)

    hash[:shippingOptions][:order][:orderid].should == "R464822726"
  end

  it "should convert from a partial path" do
    path = @xml.at_xpath("//shippingOptions/order")
    hash = HashConverter.from_xml(path, false)

    hash[:order][:orderid].should == "R464822726"
  end

  it "should verify auto type conversion" do
    path = @xml.at_xpath("//shippingOptions/order")

    hash = HashConverter.from_xml(path, false, false)
    hash[:order][:option][0][:price].should == "1.75"

    hash = HashConverter.from_xml(path, false, true)
    hash[:order][:option][0][:price].should == 1.75
  end

end
