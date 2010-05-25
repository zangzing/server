require 'rubygems'
gem 'gdata'
require 'gdata/auth'
require 'gdata/client'
require 'gdata/http'
require 'rexml/document'

class GoogleConnectController < ApplicationController

  def update
    scope = 'http://www.google.com/m8/feeds/'
    next_url = 'http://12foot3.com/authsub/redirect_to_localhost.html'
    secure = false # set secure = true for signed AuthSub requests
    sess = true
    redirect_to GData::Auth::AuthSub.get_url(next_url, scope, secure, sess)
  end

  def receive_token
    #@PRIVATE_KEY = '/Users/Shared/dev/myrsakey.pem'
    client = GData::Client::Contacts.new

    token = params["token"]

    puts "TOKEN: " + token

    client.authsub_token =  token
    #client.authsub_private_key = @PRIVATE_KEY

    upgraded_token = client.auth_handler.upgrade()

    puts "UPGRADED TOKEN: " + upgraded_token

    client = GData::Client::Contacts.new
    client.authsub_token = upgraded_token

    start_index = 1
    batch_size = 100

    contacts = []

    while true
      doc = client.get("http://www.google.com/m8/feeds/contacts/default/full?max-results=#{batch_size}&start-index=#{start_index}").to_xml

      entry_count = 0


      doc.elements.each('entry') do |entry|
        entry_count += 1

        contact = {}

        entry.elements.each('title') do |title|
          contact['name'] = title.text.to_s
        end


        entry.elements.each('gd:email') do |email|
          if email.attribute('primary')
            contact['email'] = email.attribute('address').value
          end
        end

        contacts << contact
      end

      break if (entry_count==0)

      start_index += batch_size

    end

    puts contacts.inspect
  end
end
