class Connector::MsliveController < Connector::ConnectorController
  require 'windowslivelogin'
  before_filter :service_login_required

  OFFERS = "Contacts.View" # Comma-delimited list of offers to be used.
  
protected

  def service_login_required
    unless consent_token
      @token_string = service_identity.credentials
      @consent_token = live_api.processConsentToken(@token_string)
      if consent_token
        if not consent_token.isValid?
          if (consent_token.refresh and consent_token.isValid?)
            @token_string = consent_token.token
            service_identity.update_attribute(:credentials, @token_string)
          end
        end
      end
      raise InvalidToken unless consent_token and consent_token.isValid?
    end
  end

  def service_identity
    @service_identity ||= current_user.identity_for_mslive
  end

  def live_api
    #Manage apps here: https://manage.dev.live.com
    @api ||= WindowsLiveLogin.new(WINDOWS_LIVE_API_KEYS[:client_id], WINDOWS_LIVE_API_KEYS[:secret_key], 'wsignin1.0', true, "http://#{Server::Application.config.application_host}/tos.html")
  end
  
  def consent_token
    @consent_token
  end

  def token_string
    @token_string
  end


  #Docs are here:
  # http://msdn.microsoft.com/en-us/library/bb463979.aspx
  # http://msdn.microsoft.com/en-us/library/bb463989.aspx

  def make_signed_request(url)# http://msdn.microsoft.com/en-us/library/bb463986.aspx
    
    service_uri = URI.parse(url)
    http = Net::HTTP.new(service_uri.host, service_uri.port)
    if service_uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(service_uri.request_uri, 'Authorization' => "DelegatedToken dt=\"#{consent_token.delegationtoken}\"")
    begin
      response = http.request(request)
    rescue => e
      if e.kind_of?(SocketError)
        raise HttpCallFail
      else
        raise e
      end
    end
    XmlSimple.xml_in(response.body)
  end

  CONTACTS_API_URL = 'https://livecontacts.services.live.com/users/@L@%s/REST'
  def request_contacts_service(relative_url)
    make_signed_request("#{CONTACTS_API_URL % consent_token.locationid.upcase}#{relative_url}")
    #XmlSimple.xml_in("#{Rails.root}/live_contacts.xml")
  end

end
