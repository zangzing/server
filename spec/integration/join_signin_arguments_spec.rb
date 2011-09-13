require 'spec_helper'
include PrettyUrlHelper

describe 'adding return_to and email to signin url' do
  it 'should pre-fill email/username field with email argument' do
    mail = "email@example.com"
    visit signin_pretty_url( nil, mail )
    response.status.should be 200
    field_with_id('email').value.should match mail
  end

   #it 'after login should redirect to return_to' do
   #user = Factory.create(:user)
   #photo = Factory.create(:photo)
   #return_to = photo_pretty_url( photo )
   #
   #visit signin_pretty_url( return_to, nil )
   #fill_in 'email', :with    => user.username
   #fill_in 'password', :with => 'password'
   #click_button
   #
   #response.should redirect_to(return_to)
   #end
end

describe 'adding return_to and email to join url' do
  it 'should pre-fill email/username field with email argument' do
    mail = "email@example.com"
    visit join_pretty_url( nil, mail )
    response.status.should be 200
    field_with_id('user_email').value.should match mail
  end

  #it 'should redirect to return_to' do
  #  photo = Factory.create(:photo)
  #  return_to = photo_pretty_url( photo )
  #
  #  visit join_pretty_url( return_to, nil )
  #  fill_in 'user[name]', :with     => Faker::Name.name
  #  fill_in 'user[username]', :with => Faker::Internet.user_name
  #  fill_in 'user[email]', :with    => Faker::Internet.email
  #  fill_in 'user[password]', :with => Faker::Internet.user_name
  #  click_link 'submit_button'
  #
  #  field_with_id('email').value.should match mail
  #end

end