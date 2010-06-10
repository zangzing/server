require 'rubygems'
gem 'gdata'
require 'gdata/auth'
require 'gdata/client'
require 'gdata/http'
require 'rexml/document'

class GoogleContactsController < ApplicationController

  include GoogleSessionsHelper


  def index

    puts params.inspect


    puts "RELOAD: "+ params[:reload].to_s



    if (params[:reload])
      reload
    end

    @contacts = current_user.identity_for_gmail.contacts
  end




  

  private

  def reload
    token = get_google_token

    if (!token)
      redirect_to "/google_sessions/new"
      return
    end


    identity = current_user.identity_for_gmail
    identity.contacts.each do |contact|
      contact.destroy
    end


    client = GData::Client::Contacts.new
    client.authsub_token = token


    start_index = 1
    batch_size = 100

    begin
      while true
        doc = client.get("http://www.google.com/m8/feeds/contacts/default/full?max-results=#{batch_size}&start-index=#{start_index}").to_xml

        entry_count = 0

        doc.elements.each('entry') do |entry|
          entry_count += 1

          props = {}

          entry.elements.each('title') do |title|
            props['name'] = title.text.to_s
          end


          entry.elements.each('gd:email') do |email|
            if email.attribute('primary')
              props['email'] = email.attribute('address').value
            end
          end

          if (props['email'])
            contact = identity.contacts.new
            contact.name = props['name']
            contact.address = props['email']
            contact.save
          end

        end

        break if (entry_count==0)

        start_index += batch_size

      end

      redirect_to "/google_contacts"

    rescue GData::Client::AuthorizationError => exc
      delete_token
      redirect_to "/google_sessions/new"
    end

  end


end

