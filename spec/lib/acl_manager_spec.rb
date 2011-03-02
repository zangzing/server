require "rspec"
require "lib/acl_manager"
require "redis"
require 'benchmark'
require 'system_timer'

describe "ACL Test" do

  it "should get a redis object" do

    redis = ACLManager.get_redis

    redis.should_not == nil
  end
end