class ContactsController < ApplicationController
  before_filter :require_user

  def index
    #@contacts = current_user.contacts
    #response = {}
    #@contacts.each do |contact|
    #  response << [ contact.id, contact.name, contact.address ]
    #end
    #render :json => response

    response = {}
    [:local, :google, :yahoo, :mslive ].each do |service|
      identity = current_user.send("identity_for_#{service}" )
      if( identity.has_credentials? && !identity.last_contact_refresh.nil? )
        response[service] = { :last_import => identity.last_contact_refresh, :contacts => identity.contacts }
      end
    end
    render :json => response
  end

end