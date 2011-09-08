require 'spec_helper'

describe Photo do

  it "should create and delete photo dependencies" do
    photo = Factory.create(:full_photo)
    photo_id = photo.id
    photo_id.should_not == 0
    user = photo.user
    user.destroy
    photo = Photo.find_by_id(photo_id)
    photo.should == nil
  end
end