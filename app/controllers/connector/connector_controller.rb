class Connector::ConnectorController < ApplicationController
  require 'connector_exceptions'
 
  #USER_STUB = Struct.new(:id)

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

  #def current_user
  #  USER_STUB.new(77)
  #end
private

  def check_params_for_import
      render :status => 400, :text => 'ZZ Album ID should be supplied' if params[:album_id].blank? && (controller_name.include?('folders') || controller_name.include?('photos'))
  end

end
