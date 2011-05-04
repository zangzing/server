
class Connector::GoogleContactsController < Connector::GoogleController
#  skip_before_filter :service_login_required, :only => [:index]

  BATCH_SIZE = 2000

  def self.import_contacts(api_client, params)
    identity = params.delete(:identity)
    start_index = 1
    imported_contacts = []
    entry_count = BATCH_SIZE  # use as a flag to tell us if we have more to do
    begin
      break if entry_count < BATCH_SIZE # no more to do since last fetch had less than we asked for
      doc = call_with_error_adapter do
        Nokogiri::XML(api_client.get("http://www.google.com/m8/feeds/contacts/default/full?max-results=#{BATCH_SIZE}&start-index=#{start_index}").body)
      end
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

    save_contacts(identity, imported_contacts)
    contacts_as_fast_json(imported_contacts)
  end

#  def index
#    @contacts = current_user.identity_for_google.contacts
#  end

  def import
    fire_async_response('import_contacts')
  end

end

