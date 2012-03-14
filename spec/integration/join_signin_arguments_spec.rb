require 'spec_helper'
include PrettyUrlHelper

describe 'return_to and email parameters for signin and join urls' do
  include ControllerSpecHelper


  it 'signin_url should pre-fill email/username field with email argument' do
    mail = "email@example.com"
    visit signin_pretty_url( nil, mail )
    response.status.should be 200
    field_with_id('email').value.should match mail
  end

  it 'signin_url should redirect to return_to after login' do
    user = Factory.create(:user)
    photo = Factory.create(:photo)
    return_to = photo_pretty_url( photo )

    visit signin_pretty_url( return_to, nil )
    fill_in 'email', :with    => user.username
    fill_in 'password', :with => 'password'
    submit_form 'signin-form'
    response.status.should be 200
    response.should have_selector('body#photos-index')
  end

  it 'signin_url should redirect to return_to if logged in' do
    user = Factory.create(:user)
    photo = Factory.create(:photo)
    return_to = photo_pretty_url( photo )

    visit signin_pretty_url( return_to, nil )
    fill_in 'email', :with    => user.username
    fill_in 'password', :with => 'password'
    submit_form 'signin-form'
    response.status.should be 200

    visit signin_pretty_url( return_to, nil )
    response.status.should be 200
    response.should have_selector('body#photos-index')
  end

  it 'join_url should pre-fill email/username field with email argument' do
    mail = "email@example.com"
    visit join_pretty_url( nil, mail )
    field_with_id('user_email').value.should match mail
  end

  it 'join_url should redirect to return_to after join' do
    photo = Factory.create(:photo)
    return_to = photo_pretty_url( photo )

    # visit join page
    get_via_redirect join_pretty_url(return_to)
    response.status.should be 200
    response.should have_selector('.join-form')

    # post join page (1st step)
    post_via_redirect create_user_path 'user[email]' => Faker::Internet.email, 'user[password]' => 'password'
    response.status.should be 200
    response.should have_selector('#users-finish_profile')

    # post finish profile page (2nd step)
    post_via_redirect zz_api_login_create_finish_path 'name' => Faker::Name.name, 'username' => 'username'
    response.status.should be 200

    # make sure we got redirected to the photos page
    get_via_redirect after_join_path
    response.status.should be 200
    response.should have_selector('body#photos-index')

  end

  it 'welcome dialog js directive should be present after join  if no return_to' do
    # visit join page
    get_via_redirect join_pretty_url
    response.status.should be 200
    response.should have_selector('.join-form')

    # post join page (1st step)
    post_via_redirect create_user_path 'user[email]' => Faker::Internet.email, 'user[password]' => 'password'
    response.status.should be 200
    response.should have_selector('#users-finish_profile')

    # post finish profile page (2nd step)
    post_via_redirect zz_api_login_create_finish_path 'name' => Faker::Name.name, 'username' => 'username'
    response.status.should be 200

    get_via_redirect after_join_path
    response.status.should be 200
    response.should contain("zz.welcome.show_welcome_dialog();")

  end

  it 'join_url should redirect to return_to if logged in' do
    user = Factory.create(:user)
    photo = Factory.create(:photo)
    return_to = photo_pretty_url( photo )

    visit signin_pretty_url( return_to, nil )
    fill_in 'email', :with    => user.username
    fill_in 'password', :with => 'password'
    submit_form 'signin-form'
    response.status.should be 200

    visit join_pretty_url( return_to, nil )
    response.status.should be 200
    response.should have_selector('body#photos-index')
  end


end