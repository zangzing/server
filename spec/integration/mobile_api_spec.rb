require 'spec_helper'
include PrettyUrlHelper

#def unique_name(base_name)
#  name = "#{base_name}-#{Time.now.to_i}-#{rand(99999)}"
#end
#

describe "Mobile API" do

  describe "credentials" do
    it "should fail to login" do
      path = build_full_path(mobile_login_path, true)
      post path, :email => "test1", :password => "badpassword"
      j = JSON.parse(response.body).recursively_symbolize_keys!
      pj = JSON.pretty_generate(j)
      puts pj
      j[:code].should eql(401)
    end

    it "should login" do
      path = build_full_path(mobile_login_path, true)
      post path, :email => "test1", :password => "testtest"
      response.status.should eql(200)
      login_info = JSON.parse(response.body).recursively_symbolize_keys!
      @user_id = login_info[:user_id]
      uid = login_info[:user_id]
    end
  end

  describe "albums" do
    before(:each) do
      path = build_full_path(mobile_login_path, true)
      post path, :email => "test1", :password => "testtest"
      response.status.should eql(200)
      login_info = JSON.parse(response.body).recursively_symbolize_keys!
      @user_id = login_info[:user_id]
    end

    it "should fetch albums" do
      path = build_full_path(mobile_albums_path(@user_id))
      get path
      response.status.should eql(200)
      j = JSON.parse(response.body).recursively_symbolize_keys!
      pj = JSON.pretty_generate(j)
      puts pj
      j[:public].should == false

      # verify that we have the expected data
      path = j[:liked_users_albums_path]
      path.should_not == nil
      get path
      response.status.should eql(200)
      puts response.body
      albums = JSON.parse(response.body)
      puts JSON.pretty_generate(albums)
      albums.count.should == 2
      albums.each do |album|
        album.recursively_symbolize_keys!
        name = album[:name]
       ['t2-a1', 't2-a2'].include?(name).should == true
      end
    end

    it "should fetch albums as a guest" do
      # sign out
      path = build_full_path(mobile_logout_path)
      post path
      response.status.should eql(200)

      path = build_full_path(mobile_albums_path(@user_id))
      get path
      response.status.should eql(200)
      body = response.body
      j = JSON.parse(response.body).recursively_symbolize_keys!
      pj = JSON.pretty_generate(j)
      puts pj
      j[:public].should == true
    end
  end
end