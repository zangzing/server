require 'spec_helper'
include PrettyUrlHelper

describe 'commenting as guest' do
  it 'should allow guest to enter comment then redirect to signin then back to comment after signin' do
    photo = Factory.create(:photo)
    user = Factory.create(:user)


    # go to the photo's single pic view
    get_via_redirect photo_pretty_url(photo)

    # post comment via ajax
    post_via_redirect create_photo_comment_path(photo), {:comment=>{:text => 'this is a comment'}}

    # should get redirect to sigining page that we handle in javascript
    response.status.should eql(401)
    get_via_redirect "#{signin_path}?return_to=#{CGI::escape(finish_create_photo_comment_path(photo))}"


    # signin and follow redirect back to photo single pic vuew
    post_via_redirect create_user_session_path, :email => user.email, :password => "password"


    # verify that comment has been added to database
    get_via_redirect photo_comments_url(photo)
    response.body.should match(/this is a comment/)

  end

  it 'should allow guest to enter comment then redirect to signin then back to comment after signin' do
    photo = Factory.create(:photo)



    # go to the photo's single pic view
    get_via_redirect photo_pretty_url(photo)

    # post comment via ajax
    post_via_redirect create_photo_comment_path(photo), {:comment=>{:text => 'this is a comment'}}

    # should get redirect to sigining page that we handle in javascript
    response.status.should eql(401)
    get_via_redirect "#{join_path}?return_to=#{CGI::escape(finish_create_photo_comment_path(photo))}"


    # post join page (1st step)
    post_via_redirect create_user_path 'user[email]' => Faker::Internet.email, 'user[password]' => 'password'
    response.status.should be 200
    response.should have_selector('#users-finish_profile')

    # post finish profile page (2nd step)
    post_via_redirect zz_api_login_create_finish_path 'name' => Faker::Name.name, 'username' => 'username'
    response.status.should be 200


    get_via_redirect after_join_path
    response.status.should be 200






    # verify that comment has been added to database
    get_via_redirect photo_comments_url(photo)
    response.body.should match(/this is a comment/)

  end


end