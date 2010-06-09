class FacebookSessionsController < ApplicationController

  def new
    url = HyperGraph.authorize_url('f4d63fedf5efb80582e053cde0929378', 'http://localhost:3000/facebook_sessions/create', :scope => 'publish_stream')
    #url = HyperGraph.authorize_url('f4d63fedf5efb80582e053cde0929378', 'http://localhost:3000/facebook_connect/receive_token/', :scope => 'publish_stream', :display => 'popup')
    redirect_to url
  end

  def create
    code = params["code"]

    puts "CODE: " +code

    access_token = HyperGraph.get_access_token('f4d63fedf5efb80582e053cde0929378', 'd551ae9821d42fbb22de534f70502b0b', 'http://localhost:3000/facebook_sessions/create', code)

    puts "ACCESS TOKEN: " + access_token

    session[:facebook_token] = access_token
  end

  def destroy
    session.delete(:facebook_token)
  end

  def verify
    begin
      graph = HyperGraph.new(session[:facebook_token])
      graph.get('me')[:name]
      session_status = 'OK'
    rescue FacebookError
      session_status = 'INVALID'
    end


    respond_to do |format|
      format.html {
        render :text => session_status
      }
      format.json {
        render :json => session_status.to_json
      }
      format.json {
        render :xml => session_status
      }
    end
  end
end