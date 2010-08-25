require 'test_helper'
require 'faker'

class LocalContactsImporterTest < ActionController::IntegrationTest
  #fixtures :all
  include IntegrationHelper
  def setup

  end

  test "Routing" do
    #Contact import
    assert_routing "/local/contacts/import", {:controller => "local_contacts", :action => "import"}
  end

  test "Importing" do
    # "Imoprt contacts" do
    
    contacts = [
      {'First' => 'Burton', 'Last' => 'Bell', 'Email' => 'burton@fearfactory.com'},
      {'First' => 'Otep', 'Last' => 'Shamaya', 'Email' => 'info@otep.com'},
      {'First' => 'Artem', 'Last' => 'Lotskih', 'Email' => 'nelson@stigmata.ru'},
    ]
    40.times do
      contacts << {'First' => Faker::Name.first_name, 'Last' => Faker::Name.last_name, 'Email' => Faker::Internet.email}
    end
    
    visit local_contacts_path(:action => 'import'), :post, :contacts => contacts.to_json
    visit local_contacts_path
    assert_contain "burton@fearfactory.com"
    assert_contain "info@otep.com"
    assert_contain "nelson@stigmata.ru"

  end

end