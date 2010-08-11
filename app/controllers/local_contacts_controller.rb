class LocalContactsController < ApplicationController
  before_filter :require_user

  def index
    @contacts = current_user.identity_for_local.contacts
  end

  def do_import
    contacts = []
    50.times do
      contacts << {'first' => Faker::Name.first_name, 'last' => Faker::Name.last_name, 'email' => Faker::Internet.email}
    end
    redirect_to :action => 'import', :contacts => contacts, :method => :post
  end

  def import
    identity = current_user.identity_for_local
    source_data = JSON.parse(params[:contacts]) || []

    imported_contacts = []
    source_data.each do |entry|
      props = {
        :name => [entry['first'], entry['last']].join(' ').strip,
        :address => entry['email']
      }
      next if props[:address].blank?
      props[:name] = props[:address].split('@').first unless props[:name]
      imported_contacts << Contact.new(props)
    end

    unless imported_contacts.empty?
      identity.contacts.destroy_all
      imported_contacts.each {|c| identity.contacts << c  }
      if identity.save
        redirect_to :action => 'index'
      else
        render :text => identity.errors.full_messages.join('<br/>')
      end
    else
      render :text => 'No contacts was imported'
    end
  end


end

