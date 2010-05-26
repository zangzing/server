# == Schema Information
# Schema version: 20100526143648
#
# Table name: photos
#
#  id                 :integer         not null, primary key
#  album_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#  user_id            :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

require 'spec_helper'

describe Photo do
  before( :each ) do
      @attr = { :image => File.new(RAILS_ROOT + '/public/images/rails.png')}
      @album = Factory( :album )  
  end

    it "should create a new instance given valid attributes" do
      @album.photos.build( @attr )  
    end
    
    #
    # album associations
    #
    describe "album associations" do
         before(:each) do
           @photo = @album.photos.create(@attr)
         end

         it "should have a user attribute" do
           @photo.should respond_to(:album)
         end

         it "should have the right associated album" do
           @photo.album_id.should == @album.id
           @photo.album.should == @album
         end
    end
    
    #
    # Validations
    #
    describe "validations" do
       @attr = {}
        it "should require an image" do
          Photo.new(@attr).should_not be_valid
        end
    end
   
end
