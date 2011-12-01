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

    visit join_pretty_url( return_to, nil )
    fill_in 'user[name]', :with     => Faker::Name.name
    fill_in 'user[username]', :with => Faker::Name.first_name.downcase
    fill_in 'user[email]', :with    => Faker::Internet.email
    fill_in 'user[password]', :with => 'password'
    submit_form 'join-form'
    response.status.should be 200
    response.should have_selector('body#photos-index')
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

  it 'welcome dialog js directive should be present after join  if no return_to' do
    visit join_pretty_url( nil, nil )
    fill_in 'user[name]', :with     => Faker::Name.name
    fill_in 'user[username]', :with => Faker::Name.first_name.downcase
    fill_in 'user[email]', :with    => Faker::Internet.email
    fill_in 'user[password]', :with => 'password'
    submit_form 'join-form'
    response.status.should be 200
    response.should contain("zz.welcome.show_welcome_dialog();")
  end
end