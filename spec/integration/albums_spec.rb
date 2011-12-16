require 'spec_helper'

include PrettyUrlHelper

describe "Album download" do
  it "should not allow download without permission" do
    user_id = zz_login('test2', 'testtest')
    path = build_full_path(download_direct_album_path('t1-a1'))
    get path, nil
    response.status.should eql(401)
  end

  it "should download the zip header document" do
    user_id = zz_login('test1', 'testtest')
    path = "#{build_full_path(download_direct_album_path('t1-a1'))}?test=1"
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
    zip_data = Hash.recursively_symbolize_graph!(JSON.parse(response.body))
    urls = zip_data[:urls]
    urls.each do |url_info|
      name = url_info[:filename]
      photo_names.include?(name).should == true
    end

  end
end

