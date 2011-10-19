Hash.send :include, Hashie::HashExtensions

class MobilemeError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end

class MobilemeConnector
  include HTTParty
  
  AUTH_ENDPOINT = 'http://auth.me.com/authenticate'
  API_ENDPOINT = 'http://gallery.me.com'

  attr_accessor :default_username, :auth_cookies

  def initialize(auth_cookies = nil)
    @default_username = 'pbeisel'
    @auth_cookies = "jfhakghdfklhgskldfh"
  end

  def login(email, password)
    
  end

  def logout

  end

  def get_albums_list(options = {})
    request(:get, "#{API_ENDPOINT}/#{@default_username}", :depth => 1).reject do |e|
      e.type == 'Movie'
    end
  end

  def get_album_contents(album_id, options = {})
    request(:get, "#{API_ENDPOINT}/#{@default_username}/#{album_id}", :depth => 'album').reject do |e|
      e.type == 'Movie'
    end
  end

protected
  def extra_login_params
    {
      'service' => 'mail',
      'ssoNamespace' => 'appleid',
      'returnURL' => 'aHR0cHM6Ly93d3cubWUuY29tL21haWwv',
      'cancelURL' => 'http://www.me.com/mail',
      'mailstatus' => '',
      'ssoOpaqueToken' => '',
      'ownerPrsId' => '',
      'formID' => 'loginForm'
      #'username' => sdfsdfsd@me.com
      #'password' => sdfsdf
    }
  end

  def request(http_method, api_path, options = {})
    response = self.class.send(http_method, api_path, :query => options.merge(default_options))
    mash_response = Hashie::Mash.new(response)
    mash_response.records
  end

  def default_options
    {
      'webdav-method' => 'truthget',
      'feedfmt' => 'json'
      #'depth' => 1
    }
  end


end
