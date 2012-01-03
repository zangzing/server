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


  # this one is called from an controller action
  # browser will poll for response
  # does not retry on failure
  def fire_async_response(class_method)
    response_id = AsyncResponse.new_response_id
    ZZ::Async::ConnectorWorker.enqueue(response_id, service_identity.id, self.class.name, class_method, params)
    response.headers["x-poll-for-response"] = async_response_url(response_id)
    render :json => {:message => "poll-for-response"}
  end


  # this one is called from within another worker
  # results will not be sent to browser
  # will retry on failure
  def self.fire_async(class_method, params)
    all_params = {
      :allow_retry => true
    }
    all_params.merge!(params)
    response_id = AsyncResponse.new_response_id
    ZZ::Async::ConnectorWorker.enqueue(response_id, params[:identity].id, self.name, class_method, all_params)
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

    def bulk_insert(photos, options = {})
      # bulk insert
      Photo.batch_insert(photos)

      # must send after all saved
      photos.each do |photo|
        ZZ::Async::GeneralImport.enqueue( photo.id, photo.temp_url, options )
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

    def create_album(identity, name, privacy = Album::PUBLIC)
      raise ArgumentError.new("Invalid album privacy setting - #{privacy}") unless Album::PRIVACIES.include?(privacy)
      album_type = 'PersonalAlbum'
      album = album_type.constantize.new(:name => name[0..40], :privacy => privacy) # limit name to 40 chars
      album.user = identity.user
      album.save!

      return album
    end

  end

private

  def check_params_for_import
      render :status => 400, :text => 'ZZ Album ID should be supplied' if params[:album_id].blank? && (controller_name.include?('folders') || controller_name.include?('photos'))
  end

end
