require 'spec_helper'
#require "rspec"
#require "config/application"
require "lib/old_album_acl"
#require "redis"
require 'benchmark'
require 'system_timer'

class TestAlbumACLTuple < OldBaseACLTuple
end

# implements the ACL control for Albums
class TestAlbumACL < OldBaseACL
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

  # make a tuple of our specific type
  # that holds the acl_id and role
  def self.new_tuple
    TestAlbumACLTuple.new
  end
end

# let the class initialize and register
TestAlbumACL.initialize

def clean_up_album_range(start_album_id, end_album_id, include_test_album = false)
  (start_album_id..end_album_id).each do |album_id|
    a = OldAlbumACL.new(album_id)
    a.remove_acl
    if include_test_album
      ta = TestAlbumACL.new(album_id + 10000)
      ta.remove_acl
    end
  end
end



describe "ACL Test" do

  it "should get the same redis object" do

    redis = OldACLManager.get_global_redis

    redis.should_not == nil

    redis2 = OldACLManager.get_global_redis

    redis2.should == redis
  end

  it "should make an album acl" do

    a = OldAlbumACL.new(999)

    a.should_not == nil

    a.roles.should_not == nil

    a.type.should == "Album"

    b = OldAlbumACL.new(999)

    a.type.should == b.type
    a.roles[0].should == b.roles[0]
    
    puts a.roles

  end

  it "should have different roles" do
    a = OldAlbumACL.new(999)
    t = TestAlbumACL.new(999)

    a.roles.should_not == t.roles
    a.type.should_not == t.type

  end

  it "should remove an acl" do
    a = OldAlbumACL.new(999)

    a.add_user 1000, OldAlbumACL::ADMIN_ROLE
    a.add_user 1001, OldAlbumACL::VIEWER_ROLE
    a.add_user 3000, OldAlbumACL::CONTRIBUTOR_ROLE


    removed = a.remove_acl

    removed.should == true
  end

  it "should ignore case" do
    user_id = "MyUser@myemail.com"
    alt_user_id = "myuser@myemail.com"
    a = OldAlbumACL.new(999)

    a.add_user user_id, OldAlbumACL::ADMIN_ROLE

    role = a.get_user_role(alt_user_id)
    role.should == OldAlbumACL::ADMIN_ROLE

    removed = a.remove_acl

    removed.should == true
  end

  it "should rename a user key" do
    user_id = "myuser@myemail.com"
    new_user_id = 7777
    start_album_id = 2000
    end_album_id = 2003

    (start_album_id..end_album_id).each do |album_id|
      a = OldAlbumACL.new(album_id)
      ta = TestAlbumACL.new(album_id + 10000)
      a.add_user user_id, OldAlbumACL::ADMIN_ROLE
      ta.add_user user_id, TestAlbumACL::ADMIN_ROLE
    end

    # see if user is found with correct role using existing id
    a = OldAlbumACL.new(start_album_id)
    ta = TestAlbumACL.new(start_album_id + 10000)

    role = a.get_user_role(user_id)
    role.should == OldAlbumACL::ADMIN_ROLE

    role = ta.get_user_role(user_id)
    role.should == TestAlbumACL::ADMIN_ROLE

    # now globally rename this user id
    OldACLManager.global_replace_user_key user_id, new_user_id

    # see if user is found with correct role using existing id
    role = a.get_user_role(new_user_id)
    role.should == OldAlbumACL::ADMIN_ROLE

    role = ta.get_user_role(new_user_id)
    role.should == TestAlbumACL::ADMIN_ROLE

    # clean up
    OldACLManager.global_delete_user new_user_id
    clean_up_album_range(start_album_id, end_album_id, true)
  end

  it "should delete a user" do
    user_id = 8888
    start_album_id = 2000
    end_album_id = 2003

    (start_album_id..end_album_id).each do |album_id|
      a = OldAlbumACL.new(album_id)
      ta = TestAlbumACL.new(album_id + 10000)
      a.add_user user_id, OldAlbumACL::ADMIN_ROLE
      ta.add_user user_id, TestAlbumACL::ADMIN_ROLE
    end

    # see if user is found with correct role using existing id
    a = OldAlbumACL.new(start_album_id)
    ta = TestAlbumACL.new(start_album_id + 10000)

    role = a.get_user_role(user_id)
    role.should == OldAlbumACL::ADMIN_ROLE

    role = ta.get_user_role(user_id)
    role.should == TestAlbumACL::ADMIN_ROLE

    # now delete this user id from all
    OldACLManager.global_delete_user user_id

    # see if user is found with correct role using existing id
    role = a.get_user_role(user_id)
    role.should == nil

    role = ta.get_user_role(user_id)
    role.should == nil

    clean_up_album_range(start_album_id, end_album_id, true)

  end

  it "should list roles" do
    users = [
        {"8888" =>  OldAlbumACL::ADMIN_ROLE},
        {"8889" =>  OldAlbumACL::CONTRIBUTOR_ROLE},
        {"8890" =>  OldAlbumACL::VIEWER_ROLE},
        {"8891" =>  OldAlbumACL::CONTRIBUTOR_ROLE},
        {"8892" =>  OldAlbumACL::VIEWER_ROLE},
        {"8893" =>  OldAlbumACL::VIEWER_ROLE},
        {"8894" =>  OldAlbumACL::ADMIN_ROLE},
        {"8895" =>  OldAlbumACL::CONTRIBUTOR_ROLE},
        {"8896" =>  OldAlbumACL::VIEWER_ROLE},
    ]
    admins = 2
    contribs = 3
    viewers = 4

    album_id = 2000

    # create the test album entry, make sure it doesn't exist first
    a = OldAlbumACL.new(album_id)
    a.remove_acl

    # now add the users
    users.each do |user|
      user_id = user.first[0]
      role = user.first[1]
      a.add_user user_id, role
    end

    # now fetch and check them
    check_users = a.get_users_with_role(OldAlbumACL::VIEWER_ROLE, true)
    check_users.count.should == viewers
    check_users = a.get_users_with_role(OldAlbumACL::VIEWER_ROLE, false)
    check_users.count.should == viewers + admins + contribs

    check_users = a.get_users_with_role(OldAlbumACL::CONTRIBUTOR_ROLE, true)
    check_users.count.should == contribs
    check_users = a.get_users_with_role(OldAlbumACL::CONTRIBUTOR_ROLE, false)
    check_users.count.should == contribs + admins

    check_users = a.get_users_with_role(OldAlbumACL::ADMIN_ROLE, true)
    check_users.count.should == admins
    check_users = a.get_users_with_role(OldAlbumACL::ADMIN_ROLE, false)
    check_users.count.should == admins

    a.remove_user(8888)
    a.get_user_role(8888).should == nil
    check_users = a.get_users_with_role(OldAlbumACL::ADMIN_ROLE, true)
    check_users.count.should == admins - 1

    clean_up_album_range(album_id, album_id)
  end

  it "should get all acls" do
    user_id = 1234
    start_album_id = 2000
    end_album_id = 2003
    album_count = end_album_id - start_album_id + 1

    (start_album_id..end_album_id).each do |album_id|
      a = OldAlbumACL.new(album_id)
      ta = TestAlbumACL.new(album_id)
      a.add_user user_id, OldAlbumACL::ADMIN_ROLE
      ta.add_user user_id, TestAlbumACL::CONTRIBUTOR_ROLE
    end

    tuples = OldAlbumACL.get_acls_for_user(user_id, OldAlbumACL::ADMIN_ROLE, true)
    tuples.count.should == album_count

    tuples = OldAlbumACL.get_acls_for_user(user_id, OldAlbumACL::VIEWER_ROLE, true)
    tuples.count.should == 0

    tuples = OldAlbumACL.get_acls_for_user(user_id, OldAlbumACL::VIEWER_ROLE, false)
    tuples.count.should == album_count

    tuples = TestAlbumACL.get_acls_for_user(user_id, TestAlbumACL::CONTRIBUTOR_ROLE, true)
    tuples.count.should == album_count

    tuples = TestAlbumACL.get_acls_for_user(user_id, TestAlbumACL::ADMIN_ROLE, false)
    tuples.count.should == 0

    # clean up
    OldACLManager.global_delete_user user_id
  end

  it "should validate permissions" do
    user_id = 8888
    start_album_id = 2000

    # see if user is found with correct role using existing id
    a = OldAlbumACL.new(start_album_id)

    a.add_user user_id, OldAlbumACL::ADMIN_ROLE
    a.has_permission?(user_id, OldAlbumACL::ADMIN_ROLE).should == true
    a.has_permission?(user_id, OldAlbumACL::CONTRIBUTOR_ROLE).should == true
    a.has_permission?(user_id, OldAlbumACL::VIEWER_ROLE).should == true

    a.add_user user_id, OldAlbumACL::CONTRIBUTOR_ROLE
    a.has_permission?(user_id, OldAlbumACL::ADMIN_ROLE).should == false
    a.has_permission?(user_id, OldAlbumACL::CONTRIBUTOR_ROLE).should == true
    a.has_permission?(user_id, OldAlbumACL::VIEWER_ROLE).should == true

    a.add_user user_id, OldAlbumACL::VIEWER_ROLE
    a.has_permission?(user_id, OldAlbumACL::ADMIN_ROLE).should == false
    a.has_permission?(user_id, OldAlbumACL::CONTRIBUTOR_ROLE).should == false
    a.has_permission?(user_id, OldAlbumACL::VIEWER_ROLE).should == true

    clean_up_album_range(start_album_id, start_album_id)
  end

  it "should be fast" do
    user_id = 8888
    start_album_id = 1000
    end_album_id = 2000

    Benchmark.bm(25) do |x|
      x.report('create and add') do
        1.times do |i|
          (start_album_id..end_album_id).each do |album_id|
            a = OldAlbumACL.new(album_id)
            a.add_user user_id, OldAlbumACL::ADMIN_ROLE
          end
        end
      end
    end


    a = OldAlbumACL.new(start_album_id)
    Benchmark.bm(25) do |x|
      x.report('access check') do
        10000.times do |i|
          a.has_permission?(user_id, OldAlbumACL::ADMIN_ROLE)
        end
      end
    end

    Benchmark.bm(25) do |x|
      x.report('remove albums') do
        1.times do |i|
          clean_up_album_range(start_album_id, end_album_id)
        end
      end
    end

    # now an album with a very large number of users
    Benchmark.bm(25) do |x|
      x.report('album 10k users create') do
        1.times do |i|
          a = OldAlbumACL.new(start_album_id)
          10000.times do |i|
            a.add_user user_id + i, OldAlbumACL::ADMIN_ROLE
          end
        end
      end
    end

    # now remove
    Benchmark.bm(25) do |x|
      x.report('album big users delete') do
        1.times do |i|
          clean_up_album_range(start_album_id, start_album_id)
        end
      end
    end

  end

end

