require 'spec_helper'
require 'test_utils'

include PrettyUrlHelper

describe "ZZ API" do

  describe "credentials" do
    it "should fail to login" do
      j = zz_api_post zz_api_login_path, {:email => "test1", :password => "badpassword"}, 401, true
    end

    it "should login" do
      login_info = zz_api_post zz_api_login_path, {:email => "test1", :password => "testtest"}, 200, true
      uid = login_info[:user_id]
      uid.should_not == nil
    end
  end

  describe "albums" do
    before(:each) do
      @user_id = zz_login("test1", "testtest")
    end

    it "should fetch albums and verify liked_user_albums_path and invited_users_path" do
      j = zz_api_get zz_api_albums_path(@user_id), 200
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

    it "should fetch albums as a guest" do
      # sign out
      zz_api_post zz_api_logout_path, nil, 200

      j = zz_api_get zz_api_albums_path(@user_id), 200
      #puts JSON.pretty_generate(j)
      j[:public].should == true
      j[:logged_in_user_id].should == nil
    end

    it "should fail to get user info" do
      j = zz_api_get zz_api_user_info_path(99999999), 509
      #puts JSON.pretty_generate(j)
      j[:message].should == "Couldn't find User with ID=99999999"
    end

    it "should get user info" do
      j = zz_api_get zz_api_user_info_path(@user_id), 200
      #puts JSON.pretty_generate(j)
      j[:username].should == 'test1'
    end
  end
end