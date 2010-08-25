class Connector::LocalContactsController < ApplicationController
  before_filter :oauth_required, :only => [:import]

  def index
    @contacts = current_user.identity_for_local.contacts
  end

  def import
    identity = current_user.identity_for_local
    source_data = JSON.parse(params[:contacts]) || []

    imported_contacts = []
    source_data.each do |entry|
      props = {
        :name => [entry['First'], entry['Last']].join(' ').strip,
        :address => entry['Email']
      }
      next if props[:address].blank?
      props[:name] = props[:address].split('@').first unless props[:name]
      imported_contacts << Contact.new(props)
    end

    unless imported_contacts.empty?
      identity.contacts.destroy_all
      imported_contacts.each {|c| identity.contacts << c  }
      if identity.save
        render :json => {:contact_count => imported_contacts.size}
      else
        render :status => 500, :text => identity.errors.full_messages.join(', ')
      end
    else
      render :json => {:contact_count => imported_contacts.size}
    end
  end


end

