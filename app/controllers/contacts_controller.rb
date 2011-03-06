class ContactsController < ApplicationController
  before_filter :require_user

  def index
    @contacts = current_user.contacts

    response = []
    @contacts.each do |contact|
      response << [ contact.id, contact.name, contact.address ]
    end
    render :json => response
  end

end