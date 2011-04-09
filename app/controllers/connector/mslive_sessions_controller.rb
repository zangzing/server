class Connector::MsliveSessionsController < Connector::MsliveController
  skip_before_filter :service_login_required, :only => [:new, :delauth]
  skip_before_filter :verify_authenticity_token, :only => [:delauth]


  def new
    live_api.returnurl = create_mslive_session_url
    consenturl = live_api.getConsentUrl(OFFERS)
    redirect_to consenturl
  end

  def delauth
    consent = nil
    SystemTimer.timeout_after(http_timeout) do
      consent = live_api.processConsent(params)
    end
    if (consent and consent.isValid?)
      service_identity.update_attribute(:credentials, consent.token)
    end
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
  end

end
