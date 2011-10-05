require "rspec"
require "filter_helper"

class TBase

end

class One < TBase

end

class Two < TBase

end

class Three < TBase

end

describe "FilterHelper" do

  it "should allow all" do
    filter = FilterHelper.new()
    filter.allow?("anything").should == true

    filter = FilterHelper.new({})
    filter.allow?("anything").should == true
  end

  it "should allow raise exception on bad arguments" do
    lambda {FilterHelper.new(:bad => [])}.should raise_error(ArgumentError)

    lambda {FilterHelper.new(:only => [], :except => [])}.should raise_error(ArgumentError)

    lambda {FilterHelper.new(:only => "should be array")}.should raise_error(ArgumentError)
  end

  it "should match on a class instance" do
    filter = FilterHelper.new(:only => [One, Two])
    filter.allow?(Two).should == true
  end

  it "should allow matching item only" do
    filter = FilterHelper.new(:only => ["a", "b"])
    filter.allow?("a").should == true
  end

  it "should not match wrong item for only" do
    filter = FilterHelper.new(:only => ["a", "b"])
    filter.allow?("c").should == false
  end

  it "should not allow matching except" do
    filter = FilterHelper.new(:except => ["a", "b"])
    filter.allow?("a").should == false
  end

  it "should allow matching other than except" do
    filter = FilterHelper.new(:except => ["a", "b"])
    filter.allow?("c").should == true
  end

end