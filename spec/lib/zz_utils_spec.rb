require "rspec"
require "zz_utils"

describe "ZZUtils" do

  context "Argument Tests" do
    before :each do
      @options = {:a => "1.11", :b => 2, :c => 3}
    end

    it "should require at least one" do
      required = Set.new([:a, :d])
      ZZUtils.require_at_least_one(@options, required).should == true
      lambda { ZZUtils.require_at_least_one(@options, required, true) }.should_not raise_error(ArgumentError)
    end

    it "should fail if not at least one" do
      required = Set.new([:d])
      ZZUtils.require_at_least_one(@options, required).should == false
      lambda { ZZUtils.require_at_least_one(@options, required, true) }.should raise_error(ArgumentError)
    end

    it "should require all" do
      required = Set.new([:a, :b])
      ZZUtils.require_all(@options, required).should == true
      lambda { ZZUtils.require_all(@options, required, true) }.should_not raise_error(ArgumentError)
    end

    it "should convert all to Float" do
      required = Set.new([:a, :b])
      result = ZZUtils.require_all(@options, required) do |key, value|
        Float(value)
      end
      result.should == true
      @options[:a].is_a?(Float).should == true
      @options[:a].should == 1.11

    end

    it "should fail if missing on require all" do
      required = Set.new([:a, :d])
      ZZUtils.require_all(@options, required).should == false
      lambda { ZZUtils.require_all(@options, required, true) }.should raise_error(ArgumentError)
    end

  end
end