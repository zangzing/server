require "rspec"
require "lib/acl_manager"
require "lib/album_acl"
require "redis"
require 'benchmark'
require 'system_timer'

# implements the ACL control for Albums
class TestAlbumACL < BaseACL
  ADMIN_ROLE = ACLRole.new('Admin', 1)
  CONTRIBUTOR_ROLE = ACLRole.new('Contrib', 2)

  def initialize(album_id)
    self.acl_id = album_id
    TestAlbumACL.roles ||= make_roles
    TestAlbumACL.type ||= 'TestAlbum'
  end

  def make_roles
    roles = [
        ADMIN_ROLE,
        CONTRIBUTOR_ROLE
    ]
  end
end

describe "ACL Test" do

  it "should get the same redis object" do

    redis = ACLManager.get_redis

    redis.should_not == nil

    redis2 = ACLManager.get_redis

    redis2.should == redis
  end

  it "should make an album acl" do

    a = AlbumACL.new(999)

    a.should_not == nil

    a.roles.should_not == nil

    a.type.should == "Album"

    b = AlbumACL.new(999)

    a.type.should == b.type
    a.roles[0].should == b.roles[0]
    
    puts a.roles

  end

  it "should have different roles" do
    a = AlbumACL.new(999)
    t = TestAlbumACL.new(999)

    a.roles.should_not == t.roles
    a.type.should_not == t.type

  end
end