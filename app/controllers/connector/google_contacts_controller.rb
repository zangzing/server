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
    SystemTimer.timeout_after(http_timeout) do
      begin
        doc = Nokogiri::XML(client.get("http://www.google.com/m8/feeds/contacts/default/full?max-results=#{BATCH_SIZE}&start-index=#{start_index}").body)
        entry_count = 0
        doc.xpath('//a:entry', NS).each do |entry|
          entry_count += 1
          props = {
            :name => entry.at_xpath('a:title', NS).text,
            :address => ( (entry.at_xpath('gd:email[@primary="true"]/@address', NS) || entry.xpath('gd:email/@address', NS)).text rescue '')
          }
          next if props[:address].blank?
          props[:name] = props[:address].split('@').first if props[:name].blank?
          imported_contacts << Contact.new(props)
        end
        start_index += BATCH_SIZE
      end while entry_count != 0
    end

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
        render :json => ['Something went wrong'], :status => 401
        return
      end
    end
    render :json => imported_contacts.to_json
  end
end

