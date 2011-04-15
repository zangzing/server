class Connector::MsliveContactsController < Connector::MsliveController
  skip_before_filter :service_login_required, :only => [:index]
  
  def self.import_contacts(api, params)
    service_identity = params[:identity]
    #all_contacts = nil
    #SystemTimer.timeout_after(http_timeout) do
      all_contacts = Nokogiri::XML(api.request_contacts_service('/LiveContacts/Contacts?Filter=LiveContacts(Contact(ID,CID,Profiles,Email))'))
    #end
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

    unless imported_contacts.empty?
      success = false
      Contact.transaction do
        service_identity.destroy_contacts
        success = service_identity.import_contacts(imported_contacts) > 0
        service_identity.update_attribute(:last_contact_refresh, Time.now)
        if success
          service_identity.update_attribute(:last_contact_refresh, Time.now)
        else
          raise ActiveRecord::Rollback
        end
      end
      raise 'Error! No contacts has been imported' unless success
    end

    imported_contacts.to_json
  end

  def index
    render :json => service_identity.contacts
  end

  def import
    fire_async_response('import_contacts')
  end

end
