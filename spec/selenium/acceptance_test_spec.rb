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
    @browser.open "/"
    @browser.click "css=#sign-in-button"
    @browser.type "css=#user_session_email",    "jeremyhermann@gmail.com"
    @browser.type "css=#user_session_password", "Sunvalley"
    @browser.click "css=#signin-form-submit-button"

    @browser.wait_for_page_to_load "30000"

    @browser.click "css=#new-album-button"

    wait_for_element_visible "css=#group_album_link"
    @browser.click "css=#group_album_link"

    wait_for_element_visible "css=.f_facebook"
    @browser.click "css=.f_facebook img"

    #todo: need better css selector for this
    wait_for_element_visible "css=img[src='/images/service-connect-button.jpg']"
    @browser.click "css=img[src='/images/service-connect-button.jpg']"


#    @browser.open_window "", "oauthlogin"
    @browser.select_window "oauthlogin"
    wait_for_element_visible "css=#email"


    @browser.type "css=#email", "jeremy@zangzing.com"
    @browser.type "css=#pass", "share1001photos"
    @browser.click "css=input[name=login]"


    @browser.select_window "null"
    wait_for_element_visible 'xpath=//*[text()="My Albums"]'
    @browser.click 'xpath=//*[text()="My Albums"]'

    wait_for_element_visible 'xpath=//*[text()="Small Album"]'
    @browser.click 'xpath=//*[text()="Small Album"]'

    wait_for_element_visible 'css=.filechooser.photo'
    @browser.click 'css=.filechooser.photo figure'
    sleep 1 #wait for animation


    @browser.click 'css=#wizard-share'
    @browser.click 'css=#next-step' #done button

  end
end