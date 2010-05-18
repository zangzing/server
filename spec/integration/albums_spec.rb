require 'spec_helper'

describe "Albums" do

  before(:each) do
    @user = Factory(:user)
    visit signin_path
    fill_in :email,    :with => @user.email
    fill_in :password, :with => @user.password
    click_button
  end

  describe "creation" do

    describe "failure" do

      it "should not make a new album" do
        lambda do
          visit new_user_album_path(@user)
          click_button 'Create Album'
          #response.should render_template('pages/home')
          response.should have_tag("div#errorExplanation")
        end.should_not change(Album, :count)
      end
    end

    describe "success" do

      it "should make a new album" do
        name = "Testing Album Name"
        lambda do
          visit root_path
          click_button  'Create New Album'
          fill_in :album_name, :with => name
          click_button  'Create Album'
          response.should have_tag("div.flash.success")
          response.should have_tag("h2", name)
        end.should change(Album, :count).by(1)
      end
    end
  end

  describe "destruction" do

    it "should destroy an Album" do
      # Create a album.
      visit root_path
      click_button
      fill_in :album_name, :with => "lorem ipsum"
      click_button
      visit root_path
      # Destroy it.
      lambda { click_link "delete" }.should change(Album, :count).by(-1)
    end
  end
end
