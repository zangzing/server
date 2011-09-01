require 'spec_helper'
include PrettyUrlHelper

describe 'commenting as guest' do
  it 'should allow guest to enter comment then redirect to signin then back to comment after signin' do
#    photo = Factory.create(:photo)
#    user = Factory.create(:user)
#
#
#    # go to the photo's single pic view
#    visit photo_pretty_url(photo)
#
#    # post comment via ajax
#    post create_photo_comment_path(photo), {:comment=>{:text => 'this is a comment'}}
#
#    # should get redirect to sigining page that we handle in javascript
#    response.status.should eql(401)
#    visit "#{signin_path}?return_to=#{CGI::escape(finish_create_photo_comment_path(photo))}"
#
#
#    # signin and follow redirect back to photo single pic vuew
#    post create_user_session_path, :email => user.email, :password => "password"
#    response.should be_redirect
#    response.should redirect_to(finish_create_photo_comment_url(photo))
#    get finish_create_photo_comment_url(photo) # for some reason follow_redirect! is not working
#
#    # verify that comment has been added to database
#    get photo_comments_url(photo)
#    follow_redirect!
#    response.body.should match(/this is a comment/)



  end
end