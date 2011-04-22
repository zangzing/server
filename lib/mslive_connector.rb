require 'windowslivelogin'

class MsliveConnector
  cattr_accessor :client_id, :secret_key, :tos_url

  OFFERS = "Contacts.View" # Comma-delimited list of offers to be used.
  CONTACTS_API_URL = 'https://livecontacts.services.live.com/users/@L@%s/REST'

  def initialize(token_str = nil)
    throw "API credentials are not set!" unless [self.class.client_id, self.class.secret_key, self.class.tos_url].all?
    self.token_string = token_str if token_str
  end

  def get_auth_url(callback_url)
    client.returnurl = callback_url
    client.getConsentUrl(OFFERS)
  end

  def consent_token
    @consent_token
  end

  def token_string
    consent_token.token rescue nil
  end

  def token_string=(val)
    @consent_token = client.processConsentToken(val)
  end

  def token_is_valid?
    return false unless consent_token
    consent_token.isValid?
  end

  def client
    @client ||= create_client
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
    response.body
  end

  def request_contacts_service(relative_url)
    make_signed_request("#{CONTACTS_API_URL % consent_token.locationid.upcase}#{relative_url}")
  end

protected
  def create_client
    #Manage apps here: https://manage.dev.live.com
    WindowsLiveLogin.new(self.class.client_id, self.class.secret_key, 'wsignin1.0', true, self.class.tos_url)
  end

end