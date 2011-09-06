require 'spec_helper'

describe Photo do

  it "should create a full photo" do
    photo = Factory.create(:full_photo)
    photo.save!
  end
end