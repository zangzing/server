require 'spec_helper'

describe Album do

  describe "Album.safe_find" do

    it "should hande the case where we have version numbers on slugs" do
      user = Factory.create(:user)

      album_1 = Factory.create(:album, :user=>user, :name=>Album::DEFAULT_NAME)
      album_1.friendly_id.should == 'new-album'

      album_2 = Factory.create(:album, :user=>user, :name=>Album::DEFAULT_NAME)
      album_2.friendly_id.should == 'new-album-1'
      album_2.name = "blah blah blah"
      album_2.save!

      album_3 = Factory.create(:album, :user=>user, :name=>Album::DEFAULT_NAME)
      album_3.friendly_id.should == "new-album-1--2"

      Album.safe_find(user, album_1.friendly_id)
      Album.safe_find(user, album_2.friendly_id)
      Album.safe_find(user, album_3.friendly_id)

    end

    it "should work for default friendly-id if name has not been changed" do
      user = Factory.create(:user)
      album = Factory.create(:album, :user => user)
      Album.find(album.friendly_id)
      friendly_id =  album.friendly_id

      test = Album.safe_find(user, friendly_id)

      test.id.should == album.id
    end

    it "should work for new friendly-id if name has been changed" do
      user = Factory.create(:user)
      album = Factory.create(:album, :user => user)


      album.name = "My New Album Name"
      album.save!

      test = Album.safe_find(user, album.friendly_id)

      test.id.should == album.id

    end


    it "should not work for default friendly-id if name has been changed" do
      user = Factory.create(:user)
      album = Factory.create(:album, :user => user)

      default_friendly_id = album.friendly_id

      album.name = "My New Album Name"
      album.save!

      lambda { Album.safe_find(user, default_friendly_id) }.should raise_error
    end

    it "should work for non-friendly ids" do
      user = Factory.create(:user)
      album = Factory.create(:album, :user => user)


      album.name = "My New Album Name"
      album.save!

      test = Album.safe_find(user, album.id)

      test.id.should == album.id

    end
  end
end
