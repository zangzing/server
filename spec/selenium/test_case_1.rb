require "rubygems"
require "selenium"
#require "test/unit"
#require 'xmlsimple'
require 'functions'

  $ids_config = XmlSimple.xml_in('spec/selenium/ids_data.xml', { 'KeyAttr' => 'name' })
  $input_config = XmlSimple.xml_in('spec/selenium/users_data.xml', { 'KeyAttr' => 'name' })



class NewTest < Test::Unit::TestCase
  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleniumDriver.new("localhost", 4444, "*googlechrome", $ids_config['site'], 10000);
      @selenium.start
    end
    @selenium.set_context("some_test")
  end

  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end

  def test_new
	@selenium.open "/" 
	@selenium.wait_for_page_to_load
	@selenium.click "sign-in-button"
	
	Func.new.login(@selenium)
	assert @selenium.is_text_present($input_config['test_module']['login']['login_check'])
	Func.new.create(@selenium)
	
	create_shutterfly_alboom
	
	
  end




	def create_facebook_alboom
		@selenium.click "new-album-button"
		assert !60.times{ break if (@selenium.is_text_present("Group Album") rescue false); sleep 1 }
		@selenium.click "//*[@id='group_album_link']"
		assert !60.times{ break if (@selenium.is_text_present("Choose pictures from folders on your computer or other photo sites.") rescue false); sleep 1 }
		@selenium.click "//li[@id='chooser-folder-3']/a[1]/img"
		assert !60.times{ break if (@selenium.is_text_present("My Albums") rescue false); sleep 1 }
		@selenium.click "//li[@id='chooser-folder-0']/a[1]/img"
		assert !60.times{ break if (@selenium.is_text_present("Largel Album (+)") rescue false); sleep 1 }
		@selenium.click "//li[@id='chooser-folder-1']/a[1]/img"
		assert !60.times{ break if (@selenium.is_element_present("chooser-photo-img-facebook_09e78efce81574794f9df807776ea220") rescue false); sleep 1 }
		@selenium.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267609955789/import', 'chooser-photo-img-facebook_09e78efce81574794f9df807776ea220'); return false;\"]"
		@selenium.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267606622456/import', 'chooser-photo-img-facebook_d25cec6ec25f94a6b1c274583463eb61'); return false;\"]"
		@selenium.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267603289123/import', 'chooser-photo-img-facebook_623881c2018b359f390803070c9cce00'); return false;\"]"
		@selenium.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267596622457/import', 'chooser-photo-img-facebook_2dcdf1b05ff4d0958a21a0bc9afabf45'); return false;\"]"
		@selenium.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/facebook/folders/134265089956041/photos/134267599955790/import', 'chooser-photo-img-facebook_82d52bb310c74bf4664655a3868da981'); return false;\"]"
		@selenium.click "chooser-photo-img-facebook_e747309c8e4c0350b24381da4420b200"
		assert !60.times{ break if (@selenium.is_text_present("[add to album]") rescue false); sleep 1 }
		@selenium.click "link=[add to album]"
		@selenium.click "//ul[@id='filechooser']/a[3]/img"
		assert !60.times{ break if (@selenium.is_text_present("[add to album]") rescue false); sleep 1 }
		@selenium.click "link=[add to album]"
		@selenium.click "//a[@id='next-step']/span"
		assert !60.times{ break if (@selenium.is_text_present("Album Name:") rescue false); sleep 1 }
		@selenium.type "album_name", "Facebook #{Time.now}"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.wait_for_page_to_load
	end
	
	def create_shutterfly_alboom
	    @selenium.click "new-album-button"
	    assert !60.times{ break if (@selenium.is_text_present("Group Album") rescue false); sleep 1 }
	    @selenium.click "//*[@id='group_album_link']"
		assert !60.times{ break if (@selenium.is_text_present("Choose pictures from folders on your computer or other photo sites.") rescue false); sleep 1 }
		@selenium.click "//li[@id='chooser-folder-0']/a[1]/img"
		assert !60.times{ break if (@selenium.is_element_present("link=Large Album") rescue false); sleep 1 }
		#@selenium.wait_for_pop_up "oauthlogin", "30000"		###########################
		#@selenium.select_window "name=oauthlogin"				#                         #
		#@selenium.click "link=Sign in."						#	                      #
		#@selenium.wait_for_page_to_load "30000"               	#TODO: Login to Shutterfly#
		#@selenium.type "userName", "dev@zangzing.com"			#                         #
		#@selenium.type "password", "share1001"					#                         #
		#@selenium.click "signInButton"							#						  #
		#@selenium.select_window "null"							###########################
		@selenium.click "//li[@id='chooser-folder-2']/a[1]/img"
		assert !60.times{ break if (@selenium.is_element_present("chooser-photo-img-shutterfly_b79e59468ca2cdc44376c99edfc4d3cc") rescue false); sleep 1 }
		#data = @selenium.get_attribute("//img/@id")
		#puts data
		@selenium.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/shutterfly/folders/67b0de21d036b023556a/photos/47a0d729b3127ccefb45a24c75b800000033100AZsm7dmzZtGYPbz4G/import', 'chooser-photo-img-shutterfly_b79e59468ca2cdc44376c99edfc4d3cc'); return false;\"]"
		@selenium.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/shutterfly/folders/67b0de21d036b023556a/photos/47a0d729b3127ccefb45f0b8f45500000033100AZsm7dmzZtGYPbz4G/import', 'chooser-photo-img-shutterfly_42533871f3f5f1aa4b2baa22a4bc72d3'); return false;\"]"
		@selenium.click "//figure[@onclick=\"filechooser.add_photo_to_tray('/shutterfly/folders/67b0de21d036b023556a/photos/47a0d729b3127ccefb454759b47700000033100AZsm7dmzZtGYPbz4G/import', 'chooser-photo-img-shutterfly_cac5584084b201654af6e5f296f176f1'); return false;\"]"
		@selenium.click "//a[@id='next-step']/span"
		assert !60.times{ break if (@selenium.is_text_present("Album Name:") rescue false); sleep 1 }
		@selenium.type "album_name", "Shutterfly #{Time.now}"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.click "//a[@id='next-step']/span"
		@selenium.click "//a[@id='next-step']/span"
	
	end
end

