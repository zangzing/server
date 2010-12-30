require "rubygems"
require "selenium"
require "test/unit"
require 'xmlsimple'

  $ids_config = XmlSimple.xml_in('spec/selenium/ids_data.xml', { 'KeyAttr' => 'name' })
  $input_config = XmlSimple.xml_in('spec/selenium/users_data.xml', { 'KeyAttr' => 'name' })



class Func

  	def login(some)
		@selenium = some
		@selenium.type $ids_config['test_module']['login']['login_html_id'], $input_config['test_module']['login']['login_name']
		@selenium.type $ids_config['test_module']['login']['passwd_html_id'], $input_config['test_module']['login']['login_passwd']
		@selenium.click $ids_config['test_module']['login']['send_html_id']
		@selenium.wait_for_page_to_load
	end
	
	def find
		@selenium.type $ids_config['test_module']['search']['search_html_id'], $input_config['test_module']['search']['search_string']
		@selenium.click $ids_config['test_module']['search']['send_html_id']		
	end
	
  	def create(some)
		@selenium = some
		@selenium.type $ids_config['test_module']['reg']['reg_name_id'], $input_config['test_module']['reg']['reg_name']
		@selenium.type $ids_config['test_module']['reg']['reg_login_id'], $input_config['test_module']['reg']['reg_login']
		@selenium.type $ids_config['test_module']['reg']['reg_email_id'], $input_config['test_module']['reg']['reg_email']
		@selenium.type $ids_config['test_module']['reg']['reg_pass_id'], $input_config['test_module']['reg']['reg_pass']
		@selenium.click $ids_config['test_module']['reg']['reg_confirm_id']
		@selenium.wait_for_page_to_load
	end
	
	
	
end
