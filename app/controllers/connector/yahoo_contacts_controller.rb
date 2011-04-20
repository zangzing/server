class Connector::YahooContactsController < Connector::YahooController
#  skip_before_filter :service_login_required, :only => [:index]

  BATCH_SIZE = 1000

  def self.import_contacts(api, params)
    identity = params[:identity]
    start_index = 1
    imported_contacts = []
    contacts_count = nil
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

    save_contacts(identity, imported_contacts)
    contacts_as_fast_json(imported_contacts)

  end

#  def index
#    @contacts = service_identity.contacts
#  end

  def import
    fire_async_response('import_contacts')
  end

end

