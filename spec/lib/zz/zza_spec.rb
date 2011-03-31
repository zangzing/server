require "rspec"
require "lib/zz/zza"
require 'benchmark'
require 'system_timer'

describe "ZZA Test" do

  it "should change id" do

    #To change this template use File | Settings | File Templates.
    test_id = "test/ruby"
    ZZ::ZZA.default_zza_id = test_id
    test_id.should == ZZ::ZZA.default_zza_id
  end

  it "should send data" do

    z = ZZ::ZZA.new
    test_xdata = {:counts => [1,2,3]}
    z.track_event("ruby.test", test_xdata, 1, "greg s", "http://nowhere.referrer.com", "http://somewhere.page.com/from here")

    z1 = ZZ::ZZA.new("Ruby/TestOverride")
    test2_xdata = {:counts => [4,5,6]}
    z1.xdata = test2_xdata
    z1.user_type = 1
    z1.user = "greg"
    z1.referrer_uri = "http://setbyhand.com"
    z1.page_uri = "http://mypage.com"
    z1.track_event("ruby.test")

    true.should == true
  end

  it "should go fast" do
    z = ZZ::ZZA.new
    Benchmark.bm(20) do |x|
      x.report('track_event') do
        10000.times do |i|
          z.track_event("ruby.test", i, 1, "speedy", "http://speedref.com", "http://speedpage.com")
        end
      end
    end
  end

  it "should not be unreachable" do
    ZZ::ZZA.unreachable?.should == false
  end

  it "should benchmark" do
    Benchmark.bm(20) do |x|
      x.report('SystemTimer') do
        10000.times do
          SystemTimer.timeout_after(10) do
            ur = ZZ::ZZA.unreachable?
          end
        end
      end
    end
  end

  it "should let zza finish" do
    # give sender a chance to wake up and run before
    # we leave
    ZZ::ZZA.sender.run
    # let the zza sender have a chance to operate
    # until it is no longer working
    while ZZ::ZZA.sender.has_work? do
      sleep 1
      ZZ::ZZA.sender.run
    end
  end
end