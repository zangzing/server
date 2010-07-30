class ConnectorController < ActionController::Base

  USER_STUB = Struct.new(:id)

  rescue_from(ZZ::Exceptions::InvalidToken) { |e| error_occured(401, e) }
  rescue_from(ZZ::Exceptions::InvalidCredentials) { |e| error_occured(401, e) }
  rescue_from(ZZ::Exceptions::HttpCallFail) { |e| error_occured(503, e) }

  def error_occured(status, exception)
    respond_to do |format|
      format.html { render :text => "Error #{status} - #{exception.message}", :status => status }
      format.any  { head :status => status } # only return the status code
    end
  end

  def current_user
    USER_STUB.new(77)
  end

end
