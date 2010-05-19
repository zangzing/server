require 'spec_helper'

describe AlbumsController do

  integrate_views

  describe "access control" do
    before(:each) do
       @user = Factory(:user)
       @attr = { :name => "Lorem ipsum dolor" }
       @album = Factory(:album, @attr.merge(:user => @user))
       @user.albums.stub!(:build).and_return(@album)      
    end
    it "should deny access to 'create'" do
      post :create, :user_id =>@user.id
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy'" do
      delete :destroy,  {:user_id =>@user.id, :id => @album.id }
      response.should redirect_to(signin_path)
    end
  end
  
  #
  #   create
  #
  
  describe "POST 'create'" do
    before(:each) do
       @user = test_sign_in(Factory(:user))
       @attr = { :name => "Album for Testing" }
       @album = Factory(:album, @attr.merge(:user => @user))
       @user.albums.stub!(:build).and_return(@album)
    end

    describe "failure" do
      before(:each) do
         @album.should_receive(:save).and_return(false) 
      end
      it "should render the home page" do
         post :create, {:user_id => @user.id, :album => @attr}
         response.should render_template('albums/new')
      end
    end
    describe "success" do
      before(:each) do
         @album.should_receive(:save).and_return(true)
      end
      it "should redirect to the album page" do
         post :create, {:user_id =>@user.id, :album => @attr}
         response.should redirect_to( album_path( @album ))
      end
      it "should have a flash message" do
         post :create, {:user_id =>@user.id, :album => @attr}
         flash[:success].should =~ /album created/i
      end
    end
  end
  
  #
  # destroy
  #
  
  describe "DELETE 'destroy'" do
    describe "for an unauthorized user" do
      before(:each) do
         @user = Factory(:user)
         wrong_user = Factory(:user, :email => Factory.next(:email))
         test_sign_in(wrong_user)
         @album = Factory(:album, :user => @user)
      end

       it "should deny access" do
         @album.should_not_receive(:destroy)
         delete :destroy, :id => @album
         response.should redirect_to(root_path)
       end
     end
     describe "for an authorized user" do

       before(:each) do
         @user = test_sign_in(Factory(:user))
         @album = Factory(:album, :user => @user)
         Album.should_receive(:find).with(@album).and_return(@album)
       end

       it "should destroy the album" do
         @album.should_receive(:destroy).and_return(@album)
         delete :destroy, { :id => @album, :user_id =>@user.id }
       end
     end
   end
    
end
