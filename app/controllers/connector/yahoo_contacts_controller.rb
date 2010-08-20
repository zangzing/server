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
      if service_identity.save
        redirect_to :action => 'index'
      else
        render :text => service_identity.errors.full_messages.join('<br/>')
      end
    else
      render :text => 'No contacts was imported'
    end
  end


end

