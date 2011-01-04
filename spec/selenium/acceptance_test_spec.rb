require "rspec"
require "selenium"

def wait_for_element_visible selector
  !60.times do
    if (@browser.is_element_present selector) && (@browser.is_visible selector)
      return true
    end
    sleep 1
  end

  raise 'element not found: ' + selector
end


describe "Acceptance test" do

  before(:all) do
    @browser = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      #      :browser => "*googlechrome",
      :browser => "*firefox",
      :url => "http://zzadmin:sharezzphotos@share1001photos.zangzing.com/",
      :timeout_in_second => 60,
      :javascript_framework => :jquery


    @browser.start_new_browser_session

  end

  after(:all) do
#    @browser.close_current_browser_session
  end



  it "should create album with one facebook picture" do
    username = 'user' +Time.now.to_i.to_s
    password = 'share1001photos'
    email = username + "@test.zangzing.com"

    #open site
    @browser.open "/"

    #open sign in drawer
    @browser.click "css=#sign-in-button"

    #click 'join' tab
    wait_for_element_visible "css=#step-join-off"
    @browser.click "css=#step-join-off"

    #fill in 'join fields''
    wait_for_element_visible "css=#user_name"
    @browser.type "css=#user_name",    username
    @browser.type "css=#user_username", username
    @browser.type "css=#user_email", email
    @browser.type "css=#user_password", password
    @browser.click "css=#join_form_submit_button"

    @browser.wait_for_page_to_load "30000"


    #create a new ablbum
    @browser.click "css=#new-album-button"

    #select group album
    wait_for_element_visible "css=#group_album_link"
    @browser.click "css=#group_album_link"

    #open the facebook folder
    wait_for_element_visible "css=.f_facebook"
    @browser.click "css=.f_facebook img"


    #connect via oauth
    wait_for_element_visible "css=img[src='/images/service-connect-button.jpg']" #todo: need better css selector for this
    @browser.click "css=img[src='/images/service-connect-button.jpg']"

    @browser.select_window "oauthlogin" #select the oauth sign in window
    wait_for_element_visible "css=#email"

    @browser.type "css=#email", "jeremy@zangzing.com"
    @browser.type "css=#pass", "share1001photos"
    @browser.click "css=input[name=login]"

    @browser.select_window "null" #select the main window


    #open 'My Albums'
    wait_for_element_visible 'css=a:contains("My Albums")'
    @browser.click 'css=a:contains("My Albums")'


    #open "Small Album'
    wait_for_element_visible 'css=a:contains("Small Album")'
    @browser.click 'css=a:contains("Small Album")'


    #add the first picture
    wait_for_element_visible 'css=.filechooser.photo'
    @browser.click 'css=.filechooser.photo figure'
    sleep 5 #wait for animation and facebook import #todo: is there a way to test so we don't have timing issues?


    #close the wizard
    @browser.click 'css=#wizard-share'
    @browser.click 'css=#next-step' #done button

  end
end