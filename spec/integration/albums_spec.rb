require 'spec_helper'

include PrettyUrlHelper

describe "Album download" do
  it "should not allow download without permission" do
    user_id = zz_login('test2', 'testtest')
    path = build_full_path(download_album_path('t1-a1'))
    get path, nil
    response.status.should eql(401)
  end

  it "should download the zip header document" do
    user_id = zz_login('test1', 'testtest')
    path = build_full_path(download_album_path('t1-a1'))
    get path, nil
    response.status.should eql(200)

    # build set of matches
    album = Album.find_by_user_id_and_name(user_id, 't1-a1')
    photos = album.photos
    photo_names = Set.new
    photos.each do |photo|
      photo_names.add(photo.caption)
    end

    # now convert the body into an array of strings
    # and check that we got matching responses
    lines = response.body.split("\n")
    lines.each do |line|
      name = line.split[3]  # pull out the name field
      photo_names.include?(name).should == true
    end

  end
end

