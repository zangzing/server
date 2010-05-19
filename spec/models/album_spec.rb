# == Schema Information
# Schema version: 20100513233433
#
# Table name: albums
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#

require 'spec_helper'


describe Album do
  before(:each) do
    @user = Factory(:user)  
    @attr = { :name => "Album Name Here" }
  end

  it "should create a new instance given valid attributes" do
    @user.albums.create!(@attr)
  end
  
  describe "user associations" do
    before(:each) do
      @album = @user.albums.create(@attr)
    end
    
    it "should have a user attribute" do
      @album.should respond_to(:user)
    end
    
    it "should have the right associated user" do
      @album.user_id.should == @user.id
      @album.user.should == @user
    end
  end
  
  
  describe "user associations" do
       before(:each) do
         @album = @user.albums.create(@attr)
       end

       it "should have a user attribute" do
         @album.should respond_to(:user)
       end

       it "should have the right associated user" do
         @album.user_id.should == @user.id
         @album.user.should == @user
       end
  end
  
  # 
  # Photo Association
  #
  describe "photo associations" do
    before(:each) do
      @album =  Factory(:album, :user =>@user)
      @photo1 = @album.photos.build(:image => File.new(RAILS_ROOT + '/public/images/rails.png'),
                                    :created_at => 1.day.ago )
      @photo2 = @album.photos.build(:image => File.new(RAILS_ROOT + '/public/images/rails.png'),
                                    :created_at => 1.hour.ago )        
    end

    it "should have a photos attribute" do
      @album.should respond_to(:photos)
    end

    it "should have the right photos in the right order" do
      @album.photos.should == [@photo2, @photo1]
    end
    
    it "should destroy associated photos" do
          @album.destroy
          [@photo1, @photo2].each do |photo|
            Photo.find_by_id(photo.id).should be_nil
          end
    end
  end
   
   
 
   
  
  
  describe "validations" do
    it "should require a user id" do
      Album.new(@attr).should_not be_valid
    end
    it "should require nonblank content" do
      @user.albums.build(:name => "  ").should_not be_valid
    end
    it "should reject long content" do
      @user.albums.build(:name => "a" * 141).should_not be_valid
    end
  end  
end
