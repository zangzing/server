class Connector::MsliveContactsController < Connector::MsliveController
  skip_before_filter :service_login_required, :only => [:index]

  BATCH_SIZE = 100


  def index
    render :json => service_identity.contacts
  end

  def import
    all_contacts = Nokogiri::XML(request_contacts_service('/LiveContacts/Contacts?Filter=LiveContacts(Contact(ID,CID,Profiles,Email))'))
    imported_contacts = []
    
    all_contacts.xpath('/Contacts/Contact').each do |contact|
      name = [contact.at_xpath('Profiles/Personal/FirstName'), contact.at_xpath('Profiles/Personal/LastName')].compact.map(&:text).join(' ')
      (contact.xpath('Emails/Email') || []).each do |email|
        props = {
          :name => name,
          :address => email.at_xpath('Address').text,
          :type => 'email'
        }
        next if props[:address].blank?
        props[:name] = props[:address].split('@').first if props[:name].blank?
        imported_contacts << Contact.new(props)
      end
    end
    
    unless imported_contacts.empty?
      service_identity.contacts.destroy_all
      imported_contacts.each {|c| service_identity.contacts << c  }
      service_identity.last_contact_refresh = Time.now
      if service_identity.save
        render :json => imported_contacts.to_json( :only => [ :name, :address ])
      else
        render :json => service_identity.errors.full_messages.to_json, :status => 401
      end
    else
      render :json => imported_contacts.to_json(:only => [ :name, :address ])
    end
  end

end
