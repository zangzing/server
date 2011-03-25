class Connector::LocalContactsController < ApplicationController
  before_filter :oauth_required, :only => [:import]

  def index
    @contacts = current_user.identity_for_local.contacts
  end

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

    unless imported_contacts.empty?
      success = false
      Contact.transaction do
        identity.destroy_contacts
        success = identity.import_contacts(imported_contacts) > 0
        identity.update_attribute(:last_contact_refresh, Time.now) if success
      end
      unless success
        render :json => ['Something went wrong'], :status => 401
        return
      end
    end
    render :json => imported_contacts.to_json
  end


end

