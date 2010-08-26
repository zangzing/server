class Connector::YahooContactsController < Connector::YahooController
  skip_before_filter :service_login_required, :only => [:index]

  def index
    @contacts = service_identity.contacts
  end

  def import
    contacts = contact_api.contacts
    imported_contacts = contacts.collect{ |c| Contact.new(:name => c[0], :address => c[1])  }

    unless imported_contacts.empty?
      service_identity.contacts.destroy_all
      imported_contacts.each {|c| service_identity.contacts << c  }
      service_identity.last_contact_refresh = Time.now
      if service_identity.save
        render :json => imported_contacts.to_json( :only => [ :name, :address ])
      else
        render :json => identity.errors.full_messages.to_json, :status => 401
      end
    else
      render :json => imported_contacts.to_json(:only => [ :name, :address ])
    end
  end


end

