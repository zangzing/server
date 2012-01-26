require 'spec_helper'

describe SendgridController do

  describe "#events action" do

    before(:each) do
      @mock_zza = ZZ::ZZA.new
      ZZ::ZZA.stub!(:new).and_return(@mock_zza)
    end

    it "should send <category>.click and <category>.invite_frields_url.click zza events for links to invite friends" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/invite_friends"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.invite_frields_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end

    it "should send <category>.click and <category>.join_from_invite_url.click zza events for links to invite friends" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/invitation?ref=1234sdf"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.join_from_invite_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end



    it "should send <category>.click and <category>.album_grid_url_show_add_photos_dialog.click zza events for links to add photos" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/service/albums/1234/add_photos"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.album_grid_url_show_add_photos_dialog.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end

    it "should send <category>.click and <category>.signin_url.click zza events for links to blog page" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/signin"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.signin_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end


    it "should send <category>.click and <category>.blog_url.click zza events for links to blog page" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/blog"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.blog_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end



    it "should send <category>.click and <category>.zangzing_dot_com_url.click zza events for links to join page" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.zangzing_dot_com_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end


    it "should send <category>.click and <category>.join_url.click zza events for links to join page" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/join"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.join_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end



    it "should send <category>.click and <category>.photo_url_with_comments.click zza events for links photo comment" do

      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/jlh/bowie/photos/123412341234?show_comments=true"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.album_photo_url_with_comments.click", anything(), anything(), anything(), anything(), anything())

      post :events, params
    end



    it "should send <category>.click and <category>.album_grid_url.click zza events for links to album grid view " do

      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/jlh/bowie"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.album_grid_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params
    end


    it "should send <category>.click and <category>.album_photo_url.click zza events for links to album photo" do

      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/jlh/bowie/#!123232323"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.album_photo_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params
    end



    it "should send <category>.click and <category>.user_homepage_url.click events for links to user home page" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/jlh"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.user_homepage_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params
    end

    it "should send <category>.click and <category>.like_user_url.click events for links to like a user" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/service/users/jlh/like"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.like_user_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params
    end

    it "should send <category>.click and <category>.album_activities_url.click events for links to album activities page" do

      # first url format
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/jlh/bowie/activities"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.album_activities_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params


      # second url format
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/service/albums/1000/activities"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())
      @mock_zza.should_receive(:track_event).with("foo.album_activities_url.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end


    it "should not blow up with links to other sites" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.google.com/asdfasdf/asdfasdf/asdfasdf/asdfasdf/asdfasdf/asdfasdf/asdfasdf/asdfasdf"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end

    it "should not blow up with unrecognized routes" do
      params = {
          :category => "foo",
          :event => "click",
          :email => "jeremyhermann@gmail.com",
          :url => "http://www.zangzing.com/asdfasdf/asdfasdf/asdfasdf/asdfasdf/asdfasdf/asdfasdf/asdfasdf/asdfasdf"
      }

      @mock_zza.should_receive(:track_event).with("foo.click", anything(), anything(), anything(), anything(), anything())

      post :events, params

    end



  end
end










