require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "ZZ API Groups" do

    before(:each) do
      @user_id = zz_login("test1", "testtest")
      @user = User.find(@user_id)
    end

    it "should create and validate auto wrapped user" do
      user = Factory.create(:user, :username => "grouptestuser", :email => "groupuser@grouptest.com")

      j = zz_api_get zz_api_wrap_user_group_path, 200
      j[:public].should == false
      j[:logged_in_user_id].should == @user_id

      # verify that we have the expected data
      path = j[:liked_users_albums_path]
      path.should_not == nil
      albums = zz_api_get path, 200
      albums.count.should == 2
      t2a1 = nil
      albums.each do |album|
        album.recursively_symbolize_keys!
        name = album[:name]
        ['t2-a1', 't2-a2'].include?(name).should == true
        t2a1 = album if name == 't2-a1'
      end

      t2a1.should_not == nil

      # and fetch the list of photos in an album
      photos = zz_api_get zz_api_photos_path(t2a1[:id]) + "?ver=#{t2a1[:cache_version]}", 200
      photos.length.should == t2a1[:photos_count]

      # now see if we can get invited users
      path = j[:invited_albums_path]
      path.should_not == nil
      albums = zz_api_get path, 200
    end

end