class Connector::MsliveContactsController < Connector::MsliveController
#  skip_before_filter :service_login_required, :only => [:index]
  
  def self.import_contacts(api, params)
    service_identity = params[:identity]
    all_contacts = call_with_error_adapter do
      Nokogiri::XML(api.request_contacts_service('/LiveContacts/Contacts?Filter=LiveContacts(Contact(ID,CID,Profiles,Email))'))
    end
    imported_contacts = []

    all_contacts.xpath('/Contacts/Contact').each do |contact|
      name = [contact.at_xpath('Profiles/Personal/FirstName'), contact.at_xpath('Profiles/Personal/LastName')].compact.map(&:text).join(' ')
      (contact.xpath('Emails/Email') || []).each do |email|
        props = {
          :name => name,
          :address => email.at_xpath('Address').text
        }
        next if props[:address].blank?
        props[:name] = props[:address].split('@').first if props[:name].blank?
        imported_contacts << Contact.new(props)
      end
    end

    save_contacts(service_identity, imported_contacts)
    contacts_as_fast_json(imported_contacts)

  end

#  def index
#    render :json => service_identity.contacts
#  end

  def import
    fire_async_response('import_contacts')
  end

end
