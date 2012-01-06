require 'spec_helper'

describe Album do

  describe "Album.safe_find" do

    it "should work for default friendly-id if name has not been changed" do
      user = Factory.create(:user)
      album = Factory.create(:album, :user => user)
      Album.find(album.friendly_id)
      friendly_id =  album.friendly_id

      test = Album.safe_find(friendly_id)

      test.id.should == album.id
    end

    it "should work for new friendly-id if name has been changed" do
      user = Factory.create(:user)
      album = Factory.create(:album, :user => user)


      album.name = "My New Album Name"
      album.save!

      test = Album.safe_find(album.friendly_id)

      test.id.should == album.id

    end


    it "should not work for default friendly-id if name has been changed" do
      user = Factory.create(:user)
      album = Factory.create(:album, :user => user)

      default_friendly_id = album.friendly_id

      album.name = "My New Album Name"
      album.save!

      lambda { Album.safe_find(default_friendly_id) }.should raise_error
    end

    it "should work for non-friendly ids" do
      user = Factory.create(:user)
      album = Factory.create(:album, :user => user)


      album.name = "My New Album Name"
      album.save!

      test = Album.safe_find(album.id)

      test.id.should == album.id

    end


  end

end
