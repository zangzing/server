require 'spec_helper'
require 'factory_girl'

describe "Profile Album" do

  it "should return the correct url for the default profile cover photo" do
    ProfileAlbum.default_profile_cover_url.should include '.png'
  end
end