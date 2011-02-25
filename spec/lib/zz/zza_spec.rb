require "rspec"
require "lib/zz/zza"
require 'benchmark'

describe "ZZA Test" do

  it "should change id" do

    #To change this template use File | Settings | File Templates.
    test_id = "test/ruby"
    ZZ::ZZA.default_zza_id = test_id
    test_id.should == ZZ::ZZA.default_zza_id
  end

#  it "should send data" do
#
#    z = ZZ::ZZA.new
#    test_xdata = {:counts => [1,2,3]}
#    z.track_event("ruby.test", test_xdata, 1, "greg s", "http://nowhere.referrer.com", "http://somewhere.page.com/from here")
#
#    z1 = ZZ::ZZA.new("Ruby/TestOverride")
#    test2_xdata = {:counts => [4,5,6]}
#    z1.xdata = test2_xdata
#    z1.user_type = 1
#    z1.user = "greg"
#    z1.referrer_uri = "http://setbyhand.com"
#    z1.page_uri = "http://mypage.com"
#    z1.track_event("ruby.test")
#
#    true.should == true
#  end

  it "should go fast" do
    z = ZZ::ZZA.new
    Benchmark.bm(20) do |x|
      x.report('to_json') do
        100.times do |i|
          z.track_event("ruby.test", i, 1, "speedy", "http://speedref.com", "http://speedpage.com")
        end
      end
    end
  end

  it "should be zero" do
    ZZ::ZZA.sender.zza_unreachable.should == 0
  end

  it "should let zza finish" do
    # let the zza sender have a chance to operate
    sleep 10
  end
end