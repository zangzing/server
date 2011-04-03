class Connector::ConnectorController < ApplicationController
  require 'connector_exceptions'

  layout false
  
  before_filter :require_user
  before_filter :check_params_for_import, :only => :import

  rescue_from(InvalidToken) { |e| error_occured(401, e) }
  rescue_from(InvalidCredentials) { |e| error_occured(401, e) }
  rescue_from(HttpCallFail) { |e| error_occured(503, e) }

  def error_occured(status, exception)
    respond_to do |format|
      format.html { render :text => "Error #{status} - #{exception.message}<br/>#{exception.backtrace.join('<br/>')}", :status => status }
      format.any  { head :status => status } # only return the status code
    end
  end

  def bulk_insert(photos)
    render :json => Connector::ConnectorController.bulk_insert(photos)
  end

  def fire_async_response(class_method)
    response_id = AsyncResponse.new_response_id
    ZZ::Async::ConnectorResponse.enqueue(response_id, service_identity.id, self.class.name, class_method, params)
    response.headers["x-poll-for-response"] = async_response_url(response_id)
    render :json => {:message => "poll-for-response"}
  end
  

  class << self
    include Server::Application.routes.url_helpers

    def api_from_identity
      raise "api_from_identity for #{self.to_s} is not implemented!"
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
  end


protected
  def transform_params(source_params)
    out_params = source_params.dup
    action = out_params.delete(:action)
    controller = out_params.delete(:controller)
    out_params.delete(:format)
    out_params[:method] = "#{controller.split('/').last}##{action}"
    out_params
  end
  
private

  def check_params_for_import
      render :status => 400, :text => 'ZZ Album ID should be supplied' if params[:album_id].blank? && (controller_name.include?('folders') || controller_name.include?('photos'))
  end

end
