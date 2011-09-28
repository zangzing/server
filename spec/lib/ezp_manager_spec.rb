require 'spec_helper'
require 'benchmark'

describe EZPrints::EZPManager do

  before(:all) do
    @ezp = EZPrints::EZPManager.new
  end

  it 'should benchmarks the EZPrints shipping calculator API' do
    #todo create the objects needed for an order. Currently
    # as a shortcut just doing this with an existing object since
    # we want to benchmark the EZPrints shipping API to see if it is fast enough
    order = Order.find(5)
    Benchmark.bm(25) do |x|
      x.report('EZPrints ShipCalc') do
        1.times do
          prices = @ezp.shipping_costs(order)
          prices[0][:type].should == 'FC'
          prices[0][:price].should == 1.75
        end
      end
    end
  end

  # one side effect of calling this is that ezprints
  # will call us back in the near future with a failure
  # notification so maybe we should pull this test...
  it 'should send a fake order to EZPrints' do
    order = Order.find(5)
    reference = @ezp.submit_order(order, true)
    reference.should_not == nil
  end

  # this goes through all the motions but doesn't actuall
  # submit the order because this order is in test_mode
  it 'should copy photos and submit a test_mode order' do
    resque_jobs(:except => [ZZ::Async::MailingListSync]) do
      order = Order.find(5)
      # this will kick off a chain of events
      # that copy the photos, and sends the order
      # to ezprints.  We can tell if it ran
      # by checking the order ezp_reference_id
      # to see if it changed
      old_ref_id = order.ezp_reference_id
      order.prepare_for_submit

      order.reload
      order.cleanup_photos

      new_ref_id = order.ezp_reference_id
      new_ref_id.should_not == old_ref_id

    end
  end
end
