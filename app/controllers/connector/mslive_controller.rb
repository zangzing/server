class Connector::MsliveController < Connector::ConnectorController
  before_filter :service_login_required

  def self.api_from_identity(identity)
    MsliveConnector.new(identity.credentials)
  end
  
protected

  def http_timeout
    SERVICE_CALL_TIMEOUT[:mslive]
  end

  def service_login_required
    unless live_api.consent_token
      SystemTimer.timeout_after(http_timeout) do
        live_api.token_string = service_identity.credentials
      end
      if not live_api.token_is_valid?
        SystemTimer.timeout_after(http_timeout) do
          if (live_api.consent_token.refresh and live_api.token_is_valid?)
            service_identity.update_attribute(:credentials, live_api.token_string)
          end
        end
      end
      raise InvalidToken unless live_api.consent_token and live_api.token_is_valid?
    end
  end

  def service_identity
    @service_identity ||= current_user.identity_for_mslive
  end

  def live_api
    @api ||= MsliveConnector.new
  end
  
end
