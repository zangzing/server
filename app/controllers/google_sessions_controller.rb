require 'rubygems'
gem 'gdata'
require 'gdata/auth'
require 'gdata/client'
require 'gdata/http'
require 'rexml/document'

class GoogleSessionsController < ApplicationController
  include GoogleSessionsHelper


  def new
    scope = 'http://www.google.com/m8/feeds/'
    next_url = "http://#{self.request.host}:#{self.request.port}/google_sessions/create"
    secure = false #Todo: need to use HTTPS and/or use signed request
    sess = true
    redirect_to GData::Auth::AuthSub.get_url(next_url, scope, secure, sess)
  end

  def create
    client = GData::Client::Contacts.new
    token = params["token"]
    client.authsub_token =  token
    upgraded_token = client.auth_handler.upgrade()
    client.authsub_token = upgraded_token

    #create identity if necessary
    doc = client.get("http://www.google.com/m8/feeds/contacts/default/full?max-results=1").to_xml


    doc.elements.each('id') do |id|
      save_google_token(id.text, upgraded_token)
      break
    end


    redirect_to '/google_contacts'
  end

  def destroy
    session.delete(:google_token)
  end

end