class Connector::GoogleContactsController < Connector::GoogleController
  skip_before_filter :service_login_required, :only => [:index]

  BATCH_SIZE = 100

  def index
    @contacts = current_user.identity_for_google.contacts
  end

  def import
    identity = current_user.identity_for_google
    start_index = 1
    imported_contacts = []
    begin
      doc = Nokogiri::XML(client.get("http://www.google.com/m8/feeds/contacts/default/full?max-results=#{BATCH_SIZE}&start-index=#{start_index}").body)

      entry_count = 0
      doc.xpath('//a:entry', NS).each do |entry|
        entry_count += 1
        props = {
          :name => entry.at_xpath('a:title', NS).text,
          :address => ( (entry.at_xpath('gd:email[@primary="true"]/@address', NS) || entry.xpath('gd:email/@address', NS)).text rescue ''),
          :type => 'email'
        }
        next if props[:address].blank?
        props[:name] = props[:address].split('@').first unless props[:name]
        imported_contacts << Contact.new(props)
      end
      start_index += BATCH_SIZE
    end while entry_count != 0

    unless imported_contacts.empty?
      identity.contacts.destroy_all
      imported_contacts.each {|c| identity.contacts << c  }
      identity.last_contact_refresh = Time.now
      if identity.save
        render :json => imported_contacts.to_json( :only => [ :name, :address ])
      else
        render :json => identity.errors.full_messages.to_json, :status => 401
      end
    else
      render :json => imported_contacts.to_json(:only => [ :name, :address ])
    end
  end
end

