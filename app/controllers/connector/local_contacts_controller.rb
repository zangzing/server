class Connector::LocalContactsController < Connector::ConnectorController
  skip_before_filter :verify_authenticity_token, :only => [:import]
  skip_before_filter :check_token_presence, :only => [:import]
  skip_before_filter :require_user, :only => [:import]
  before_filter :oauth_required, :only => [:import]


#  def index
#    @contacts = current_user.identity_for_local.contacts
#  end

  def import
    identity = current_user.identity_for_local
    source_data = (  params[:contacts] ? JSON.parse(params[:contacts]) : [] )
    imported_contacts = []
    source_data.each do |entry|
      props = {
        :name => [entry['First'], entry['Last']].join(' ').strip,
        :address => entry['Email']
      }
      next if props[:address].blank?
      props[:name] = props[:address].split('@').first if props[:name].blank?
      imported_contacts << Contact.new(props)
    end

    Connector::ConnectorController.save_contacts(identity, imported_contacts)
    render :json => Connector::ConnectorController.contacts_as_fast_json(imported_contacts)

    
  end


end

