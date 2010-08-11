require 'test_helper'
require 'faker'

class LocalContactsImporterTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup
    ensure_logged_in
  end

  test "Routing" do
    #Contact import
    assert_routing "/local/contacts", {:controller => "local_contacts", :action => "index"}
    assert_routing "/local/contacts/import", {:controller => "local_contacts", :action => "import"}
  end

  test "Importing" do
    # "Imoprt contacts" do
    
    contacts = [
      {'first' => 'Burton', 'last' => 'Bell', 'email' => 'burton@fearfactory.com'},
      {'first' => 'Otep', 'last' => 'Shamaya', 'email' => 'info@otep.com'},
      {'first' => 'Artem', 'last' => 'Lotskih', 'email' => 'nelson@stigmata.ru'},
    ]
    40.times do
      contacts << {'first' => Faker::Name.first_name, 'last' => Faker::Name.last_name, 'email' => Faker::Internet.email}
    end
    
    visit local_contacts_path(:action => 'import'), :post, :contacts => contacts
    visit local_contacts_path
    assert_contain "burton@fearfactory.com"
    assert_contain "info@otep.com"
    assert_contain "nelson@stigmata.ru"

  end

end