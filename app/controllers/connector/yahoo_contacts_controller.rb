class Connector::YahooContactsController < Connector::YahooController
  skip_before_filter :service_login_required, :only => [:index]

  BATCH_SIZE = 100


  def index
    @contacts = service_identity.contacts
  end

  def import
    identity = current_user.identity_for_yahoo
    start_index = 1
    imported_contacts = []
    contacts_count = nil
    begin
      contacts_page = nil
      SystemTimer.timeout_after(http_timeout) do
        contacts_page = yahoo_api.get_contacts(yahoo_api.current_user_guid, :count => BATCH_SIZE, :start => start_index)
      end
      contacts_count = contacts_page[:total] unless contacts_count
      entry_count = 0
      (contacts_page[:contact] || []).each do |entry|
        entry_count += 1

        entry_fields = {}
        entry[:fields].each{|f| entry_fields[f[:type].to_sym] = f[:value] }

        props = {
          :name => (entry_fields[:name].values.reject(&:blank?).join(' ') rescue ''),
          :address => entry_fields[:email],
          :type => 'email'
        }
        next if props[:address].blank?
        props[:name] = props[:address].split('@').first if props[:name].blank?
        imported_contacts << Contact.new(props)
      end
      start_index += BATCH_SIZE
    end while start_index < contacts_count

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

