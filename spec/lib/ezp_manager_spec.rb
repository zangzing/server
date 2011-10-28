require 'spec_helper'
require 'benchmark'

describe EZPrints::EZPManager do
  def test_order_id
    10
  end

  before(:all) do
    @ezp = EZPrints::EZPManager.new
  end

  it 'should benchmarks the EZPrints shipping calculator API' do
    #todo create the objects needed for an order. Currently
    # as a shortcut just doing this with an existing object since
    # we want to benchmark the EZPrints shipping API to see if it is fast enough
    order = Order.find(test_order_id)
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
    order = Order.find(test_order_id)
    reference = @ezp.submit_order(order, true)
    reference.should_not == nil
  end

  # this goes through all the motions but doesn't actually
  # submit the order because this order is in test_mode
  it 'should copy photos and submit a test_mode order' do
      # no simulator resque jobs since we just want to test the prep phase
    resque_jobs(:except => [ZZ::Async::MailingListSync, ZZ::Async::EZPSimulator]) do
      order = Order.find(test_order_id)
      # this will kick off a chain of events
      # that copy the photos, and sends the order
      # to ezprints.  We can tell if it ran
      # by checking the order ezp_reference_id
      # to see if it changed
      old_ref_id = order.ezp_reference_id
      order.test_mode = true
      order.state = 'complete'  # test expects to start from the complete state
      order.save
      order.prepare!

      order.reload
      order.cleanup_photos

      new_ref_id = order.ezp_reference_id
      new_ref_id.should_not == old_ref_id

    end
  end

  # test the marketing photo features
  it 'should verify that we get nil when marketing album does not exist' do
    @ezp.marketing_insert('baduser', 'badalbum').should == nil

    photo = Factory.create(:photo)
    user = photo.user
    album = photo.album
    @ezp.marketing_insert(user.username, album.name).should == nil

    # album with no ready photos should also return nil
    photo.destroy
    @ezp.marketing_insert(user.username, album.name).should == nil
  end

  it 'should verify that we pick a marketing photo' do
    photo = Factory.create(:photo, :state => 'ready')
    user = photo.user
    album = photo.album
    test_photos = Set.new( [photo.id] )

    # create 10 more and add the ids to the set
    5.times do
      test_photo = Factory.create(:photo, :user => user, :album => album, :state => 'ready')
      test_photos << test_photo.id
    end

    # try a few times to make sure we don't get nil back
    6.times do
      pick = @ezp.marketing_insert(user.username, album.name)
      pick.should_not == nil
      test_photos.include?(pick).should_not == nil
    end
  end


end
