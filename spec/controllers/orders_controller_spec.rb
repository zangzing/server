require 'spec_helper'

describe OrdersController do
  include ControllerSpecHelper


  describe "#add_to_order" do
    it "should accept preoduct_id, sku and array of photo_ids and add them to order" do
      resque_jobs(:only => []) do
        photo_1 = Factory.create(:photo)
        photo_2 = Factory.create(:photo)

        params = {
            :product_id => 941187647,    # this is defined in the server_test.seed
            :sku => 90140,               # this is defined in the server_test.seed
            :photo_ids => [photo_1.id, photo_2.id],
            :format => "json"
        }

        xhr :post, :add_to_order, params

        response.status.should be(201)

        order_hash = JSON.parse(response.body)
        order = Order.find(order_hash['id'])

        order.line_items.length.should == 2


      end
    end
  end
end

