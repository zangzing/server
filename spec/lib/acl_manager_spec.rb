require "rspec"
require "lib/album_acl"
require "redis"
require 'benchmark'
require 'system_timer'

# implements the ACL control for Albums
class TestAlbumACL < BaseACL
  ADMIN_ROLE = ACLRole.new('Admin', 1)
  CONTRIBUTOR_ROLE = ACLRole.new('Contrib', 2)

  def self.initialize
    if TestAlbumACL.initialized.nil?
      TestAlbumACL.base_init 'TestAlbum', make_roles
    end
  end

  def self.make_roles
    roles = [
        ADMIN_ROLE,
        CONTRIBUTOR_ROLE
    ]
  end

  def initialize(album_id)
    TestAlbumACL.initialize
    self.acl_id = album_id
  end

end

# let the class initialize and register
TestAlbumACL.initialize

def clean_up_album_range(start_album_id, end_album_id)
  (start_album_id..end_album_id).each do |album_id|
    a = AlbumACL.new(album_id)
    ta = TestAlbumACL.new(album_id + 10000)
    a.remove_acl
    ta.remove_acl
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

  it "should remove an acl" do
    a = AlbumACL.new(999)

    a.add_user_to_acl 1000, AlbumACL::ADMIN_ROLE
    a.add_user_to_acl 1001, AlbumACL::VIEWER_ROLE
    a.add_user_to_acl 3000, AlbumACL::CONTRIBUTOR_ROLE


    removed = a.remove_acl

    removed.should == true
  end

  it "should rename a user key" do
    user_id = "myuser@myemail.com"
    new_user_id = 7777
    start_album_id = 2000
    end_album_id = 2003

    (start_album_id..end_album_id).each do |album_id|
      a = AlbumACL.new(album_id)
      ta = TestAlbumACL.new(album_id + 10000)
      a.add_user_to_acl user_id, AlbumACL::ADMIN_ROLE
      ta.add_user_to_acl user_id, TestAlbumACL::ADMIN_ROLE
    end

    # see if user is found with correct role using existing id
    a = AlbumACL.new(start_album_id)
    ta = TestAlbumACL.new(start_album_id + 10000)

    role = a.get_user_role(user_id)
    role.should == AlbumACL::ADMIN_ROLE

    role = ta.get_user_role(user_id)
    role.should == TestAlbumACL::ADMIN_ROLE

    # now globally rename this user id
    ACLManager.replace_user_key user_id, new_user_id

    # see if user is found with correct role using existing id
    role = a.get_user_role(new_user_id)
    role.should == AlbumACL::ADMIN_ROLE

    role = ta.get_user_role(new_user_id)
    role.should == TestAlbumACL::ADMIN_ROLE

    # clean up
    ACLManager.delete_user new_user_id
    clean_up_album_range(start_album_id, end_album_id)
  end

  it "should delete a user" do
    user_id = 8888
    start_album_id = 2000
    end_album_id = 2003

    (start_album_id..end_album_id).each do |album_id|
      a = AlbumACL.new(album_id)
      ta = TestAlbumACL.new(album_id + 10000)
      a.add_user_to_acl user_id, AlbumACL::ADMIN_ROLE
      ta.add_user_to_acl user_id, TestAlbumACL::ADMIN_ROLE
    end

    # see if user is found with correct role using existing id
    a = AlbumACL.new(start_album_id)
    ta = TestAlbumACL.new(start_album_id + 10000)

    role = a.get_user_role(user_id)
    role.should == AlbumACL::ADMIN_ROLE

    role = ta.get_user_role(user_id)
    role.should == TestAlbumACL::ADMIN_ROLE

    # now delete this user id from all
    ACLManager.delete_user user_id

    # see if user is found with correct role using existing id
    role = a.get_user_role(user_id)
    role.should == nil

    role = ta.get_user_role(user_id)
    role.should == nil

    clean_up_album_range(start_album_id, end_album_id)

  end

  it "should be fast" do
    user_id = 8888
    start_album_id = 2000
    end_album_id = 7000

    Benchmark.bm(20) do |x|
      x.report('create and add') do
        1.times do |i|
          (start_album_id..end_album_id).each do |album_id|
            a = AlbumACL.new(album_id)
            a.add_user_to_acl user_id, AlbumACL::ADMIN_ROLE
          end
        end
      end
    end


    a = AlbumACL.new(start_album_id)
    Benchmark.bm(20) do |x|
      x.report('access check') do
        10000.times do |i|
          a.get_user_role(user_id)
        end
      end
    end

    clean_up_album_range(start_album_id, end_album_id)

  end

end

