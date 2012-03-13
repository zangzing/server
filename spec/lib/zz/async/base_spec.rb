require 'spec_helper'

module ZZ
  module Async
    # test class that gets copy of original Base state
    # and adds extra it's own exceptions
    class TestBaseOriginal < Base
        @queue = Priorities.io_queue_name(Priorities.default_priority)

        # first get rid of the named exception name
        self.dont_retry_filter.delete(RuntimeError.name)
        # now use actual exception instead
        self.dont_retry_filter[RuntimeError] = /^my test message/i
    end

    # test class to verify class inheritable accessors working as expected
    class TestBase < Base
        @queue = Priorities.io_queue_name(Priorities.default_priority)

        self.dont_retry_filter["RuntimeError"] = /Test/i
    end
  end
end

class BaseTestException < Exception

end

class ChildOfBaseTestException < BaseTestException

end

class ShouldNotMatchException < BaseTestException

end

describe "Base resque worker class" do

  it "should have a separate inheritable class instance for two classes" do
    b = ZZ::Async::Base.new
    tb = ZZ::Async::TestBase.new

    b.dont_retry_filter["SyntaxError"].should == tb.dont_retry_filter["SyntaxError"]
    b.dont_retry_filter["RuntimeError"].should_not == tb.dont_retry_filter["RuntimeError"]
    b.dont_retry_filter.should_not == tb.dont_retry_filter

    b.dont_retry_filter["SyntaxError"] = nil
    b.dont_retry_filter["SyntaxError"].should_not == tb.dont_retry_filter["SyntaxError"]

    tb.dont_retry_filter["SyntaxError"] = nil
    b.dont_retry_filter["SyntaxError"].should == tb.dont_retry_filter["SyntaxError"]

    b.dont_retry_filter["NewError"] = /test/
    b.dont_retry_filter["NewError"].should_not == tb.dont_retry_filter["NewError"]

    b2 = ZZ::Async::Base.new
    b.dont_retry_filter.should == b2.dont_retry_filter
  end
end

describe "Base resque worker class should_retry" do

  it "should match the expected error string and exception" do
    b = ZZ::Async::TestBaseOriginal.new

    ex = ShouldNotMatchException.new "should not find"
    b.class.should_retry(ex).should == true

    ex = RuntimeError.new "Exception matches but message shouldn't"
    b.class.should_retry(ex).should == true

    ex = BaseTestException.new "Anything we want"
    b.class.should_retry(ex).should == true

    ex = RuntimeError.new "My Test Message to match"
    # when we match, should_retry returns false
    b.class.should_retry(ex).should == false

    ex = RuntimeError.new "My Test Message to match"
    # when we match, should_retry returns false
    # get rid of RuntimeError match on this class
    b.dont_retry_filter.delete(RuntimeError)
    b.class.should_retry(ex).should == true


  end
end