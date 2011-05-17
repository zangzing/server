class Connector::ConnectorController < ApplicationController
  layout false
  
  before_filter :require_user
  before_filter :check_params_for_import, :only => :import
  
  #before_filter :service_login_required  #Need to wipe out this method later
  before_filter :check_token_presence, :except => [:new, :create, :delauth]


  rescue_from(InvalidToken) { |e| error_occured(401, e) }
  rescue_from(HttpCallFail) { |e| error_occured(503, e) }

  def error_occured(status, exception)
    respond_to do |format|
      format.html { render :text => "Error #{status} - #{exception.message}<br/>#{exception.backtrace.join('<br/>')}", :status => status }
      format.any  { head :status => status } # only return the status code
    end
  end
  
  def check_token_presence
    throw "service_identity method is not defined" unless defined?(service_identity)
    raise InvalidToken.new('Auth token is absent') if service_identity.credentials.blank?
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
if photo.temp_url.nil? || photo.temp_url.empty?
  Rails.logger.error("GENERAL_IMPORT_EMPTY_URL_ERROR")
end
        ZZ::Async::GeneralImport.enqueue( photo.id, photo.temp_url )
      end

      Photo.to_json_lite(photos)
    end

    def call_with_error_adapter
      begin
        yield
      rescue SocketError => se
        raise HttpCallFail
      rescue Exception => e
        raise moderate_exception(e) || e
      end
    end
    
    def moderate_exception(exception) #Should be overridden in connectors
      nil 
    end

  end

private

  def check_params_for_import
      render :status => 400, :text => 'ZZ Album ID should be supplied' if params[:album_id].blank? && (controller_name.include?('folders') || controller_name.include?('photos'))
  end

end
