require "rubygems"
require "selenium"
#require "test/spec"
require 'spec/selenium/functions'

  $ids_config = XmlSimple.xml_in('spec/selenium/ids_data.xml', { 'KeyAttr' => 'name' })
  $input_config = XmlSimple.xml_in('spec/selenium/users_data.xml', { 'KeyAttr' => 'name' })


describe "Untitled" do
  attr_reader :selenium_driver
  alias :page :selenium_driver

  before(:all) do
    @verification_errors = []
    @selenium_driver = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*googlechrome",
      :url => "http://zzadmin:sharezzphotos@share1001photos.zangzing.com/",
      :timeout_in_second => 60
  end

  before(:each) do
    @selenium_driver.start_new_browser_session
  end
  
  after(:each) do
    @selenium_driver.close_current_browser_session
    @verification_errors.should == []
  end
  
  
  it "Album adding" do
	page.open "/"
	page.click "//div[@id='sign-in-button']/div"
	page.type "user_session_email", "lass.ua+13@gmail.com"
	page.type "user_session_password", "123456"
	page.click "//a[@id='signin-form-submit-button']/span"
	page.wait_for_page_to_load "30000"
	#page.is_text_present("by karamba").should be_true
   	page.click "new-album-button"
    !60.times{ break if (page.is_text_present("Choose Album Type") rescue false); sleep 1 }
	page.click "//*[@id='group_album_link']"
    !60.times{ break if (page.is_text_present("Choose pictures from folders on your computer or other photo sites.") rescue false); sleep 1 }
    page.click "//li[@id='chooser-folder-3']/a[1]/img"
    !60.times{ break if (page.is_text_present("My Albums") rescue false); sleep 1 }
    page.click "//li[@id='chooser-folder-0']/a[1]/img"
    !60.times{ break if (page.is_text_present("Largel Album") rescue false); sleep 1 }
    page.click "//li[@id='chooser-folder-1']/a[1]/img"
    !60.times{ break if ("" == page.get_text("chooser-photo-img-facebook_2dcdf1b05ff4d0958a21a0bc9afabf45") rescue false); sleep 1 }
    page.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267606622456/import', 'chooser-photo-img-facebook_d25cec6ec25f94a6b1c274583463eb61'); return false;\"]"
    page.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267583289125/import', 'chooser-photo-img-facebook_46470737f45089e7b86cf88c5486d75b'); return false;\"]"
    page.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267586622458/import', 'chooser-photo-img-facebook_b10c15a9bc6168f659d48b048dd4b1ae'); return false;\"]"
    page.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267589955791/import', 'chooser-photo-img-facebook_a3d0070ceb1d940f9f666f48686717d6'); return false;\"]"
    page.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267319955818/import', 'chooser-photo-img-facebook_e925cb8edc6878d9672755a52feab44b'); return false;\"]"
    page.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267599955790/import', 'chooser-photo-img-facebook_82d52bb310c74bf4664655a3868da981'); return false;\"]"
    page.click "//a[@id='next-step']/span"
    !60.times{ break if (page.is_text_present("Album Name:") rescue false); sleep 1 }
    page.type "album_name", "Facebook #{Time.now}"
    page.click "//a[@id='next-step']/span"
    page.click "//a[@id='next-step']/span"
    page.click "//a[@id='next-step']/span"
    page.click "//a[@id='next-step']/span"
    page.click "//a[@id='next-step']/span"
    page.wait_for_page_to_load "30000"
  end
    
end
