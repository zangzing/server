class Connector::ConnectorController < ApplicationController
  layout false
  
  before_filter :require_user
  before_filter :check_params_for_import, :only => :import

  rescue_from(InvalidToken) { |e| error_occured(401, e) }
  rescue_from(HttpCallFail) { |e| error_occured(503, e) }

  def error_occured(status, exception)
    respond_to do |format|
      format.html { render :text => "Error #{status} - #{exception.message}<br/>#{exception.backtrace.join('<br/>')}", :status => status }
      format.any  { head :status => status } # only return the status code
    end
  end


  def fire_async_response(class_method)
    response_id = AsyncResponse.new_response_id
    ZZ::Async::ConnectorWorker.enqueue(response_id, service_identity.id, self.class.name, class_method, params)
    response.headers["x-poll-for-response"] = async_response_url(response_id)

#    expires_in 3.minutes, :public => false
    render :json => {:message => "poll-for-response"}
  end

  def http_timeout
    return 30.seconds
  end



  # take the contact objects passed and save them in bulk to the database
  def self.save_contacts(identity, imported_contacts)
    unless imported_contacts.empty?
      Contact.transaction do
        identity.destroy_contacts
        identity.import_contacts(imported_contacts) > 0
        identity.update_attribute(:last_contact_refresh, Time.now)
      end
    end
  end

  def self.contacts_as_fast_json(imported_contacts)
    rows = []
    imported_contacts.each do |contact|
      rows << contact.as_json
    end
    JSON.fast_generate(rows)
  end

  class << self
    include Server::Application.routes.url_helpers

    def api_from_identity
      raise "api_from_identity for #{self.name.to_s} is not implemented!"
    end

    def bulk_insert(photos)
      # bulk insert
      Photo.batch_insert(photos)

      # must send after all saved
      photos.each do |photo|
        ZZ::Async::GeneralImport.enqueue( photo.id, photo.temp_url )
      end

      Photo.to_json_lite(photos)
    end
    
    def classify_exception(exception)
      return exception if [InvalidToken, InvalidCredentials, HttpCallFail].include?(exception)
      
      case exception
        when
          #Shutterfly
          ShutterflyError,
          #Facebook
          FacebookError,
          #Flickr
          FlickRaw::FailedResponse,
          #Google
          GData::Client::AuthorizationError,
          GData::Client::Error,
          GData::Client::CaptchaError,
          #Instagram
          Instagram::Error,
          Instagram::InvalidSignature,
          #Photobucket
          PhotobucketError,
          #SmugMug
          SmugmugError,
          #Kodak
          KodakError,
          #Twitter
          TwitterError,
          #Yahoo
          YahooError
            then InvalidToken

        #when 6 then InvalidCredentials    #dunno what to put here

        when
          #Common
          SocketError,
          #Google
          GData::Client::ServerError,
          GData::Client::UnknownError,
          GData::Client::VersionConflictError,
          GData::Client::RequestError,
          GData::Client::BadRequestError,
          #Instagram
          Instagram::BadRequest,
          Instagram::NotFound,
          Instagram::InternalServerError,
          Instagram::ServiceUnavailable
            then HttpCallFail

        else StandardError
      end
    end

  end

private

  def check_params_for_import
      render :status => 400, :text => 'ZZ Album ID should be supplied' if params[:album_id].blank? && (controller_name.include?('folders') || controller_name.include?('photos'))
  end

end
