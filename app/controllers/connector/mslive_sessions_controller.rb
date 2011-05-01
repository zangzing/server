class Connector::MsliveSessionsController < Connector::MsliveController
  skip_before_filter :service_login_required, :only => [:new, :delauth, :destroy]
  skip_before_filter :require_user, :only => [:new, :delauth]

  skip_before_filter :verify_authenticity_token, :only => [:delauth]


  def new
    consenturl = live_api.get_auth_url(create_mslive_session_url)
    redirect_to consenturl
  end

  def delauth
    consent = nil
    if params['ResponseCode']=='RequestRejected'
      @error = 'You must grant access to import contacts'
    else  
      SystemTimer.timeout_after(http_timeout) do
        consent = live_api.client.processConsent(params)
      end
      if (consent and consent.isValid?)
        service_identity.update_attribute(:credentials, consent.token)
      end
    end
    render 'connector/sessions/create'
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    render 'connector/sessions/destroy'
  end

end
