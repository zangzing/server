class Connector::YahooContactsController < Connector::YahooController
  skip_before_filter :service_login_required, :only => [:index]

  BATCH_SIZE = 1000
  
  def self.import_contacts(api, params)
    identity = params[:identity]
    start_index = 1
    imported_contacts = []
    contacts_count = nil
    #SystemTimer.timeout_after(http_timeout) do
      begin
        contacts_page = api.get_contacts(api.current_user_guid, :count => BATCH_SIZE, :start => start_index)
        contacts_count = contacts_page[:total] unless contacts_count
        entry_count = 0
        (contacts_page[:contact] || []).each do |entry|
          entry_count += 1

          entry_fields = {}
          entry[:fields].each{|f| entry_fields[f[:type].to_sym] = f[:value] }

          props = {
            :name => (entry_fields[:name].values.reject(&:blank?).join(' ') rescue ''),
            :address => entry_fields[:email]
          }
          next if props[:address].blank?
          props[:name] = props[:address].split('@').first if props[:name].blank?
          imported_contacts << Contact.new(props)
        end
        start_index += BATCH_SIZE
      end while start_index < contacts_count
    #end

    unless imported_contacts.empty?
      success = false
      Contact.transaction do
        identity.destroy_contacts
        success = identity.import_contacts(imported_contacts) > 0
        if success
          identity.update_attribute(:last_contact_refresh, Time.now)
        else
          raise ActiveRecord::Rollback
        end
      end
      unless success
        raise 'Error! No contacts has been imported' unless success
        return
      end
    end

    imported_contacts.to_json
  end

  def index
    @contacts = service_identity.contacts
  end

  def import
    fire_async_response('import_contacts')
  end

end

