require 'spec_helper'
include PrettyUrlHelper

describe 'album_pretty_url_show_add_photos_dialog' do
  it 'should take user to album and open add photos dialog if user is signed in' do
    pending 'not implemented yet'
    #album = Factory.create(:album)
    #user = Factory.create(:user)
    #album.add_contributors(contributor.my_group_id)
    #
    #get_via_redirect signin_path
    #
    #post_via_redirect create_user_session_path, :email => user.email, :password => "password"
    #
    #get_via_redirect album_pretty_url_show_add_photos_dialog(album)
    #
    ## this triggers javascript to show the add photos dialog
    #flash[:show_add_photos_dialog].should == true
  end


  it 'should take user to join screen then to album and open add photos dialog if user is not signed in' do
    pending 'not implemented yet'

    #album = Factory.create(:album)
    #user = Factory.create(:user)
    #album.add_contributors(user.my_group_id)
    #
    #get_via_redirect album_pretty_url_show_add_photos_dialog(album)
    #
    #request.path.should match('https:.*/join')
    #
    #get_via_redirect signin_path
    #
    #post_via_redirect create_user_session_path, :email => user.email, :password => "password"
    #
    ## this triggers javascript to show the add photos dialog
    #flash[:show_add_photos_dialog].should == true
  end


end
