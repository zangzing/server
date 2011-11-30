Hash.send :include, Hashie::HashExtensions

class MobilemeError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end

require 'faraday'

class MobilemeConnector

  AUTH_ENDPOINT = 'https://auth.me.com/authenticate'
  API_ENDPOINT = 'https://www.me.com/ro/%s/Galleries' #?webdav-method=truthget&feedfmt=galleryowner&depth=1&synchronize=true&lang=en
  TOKEN_SPLITTER = '<//>'

  attr_accessor :default_username, :auth_cookies

  def initialize(token = nil)
    self.token = token if token
  end

  def token=(val)
    data = YAML.load(val)
    @auth_cookies = data[:cookies]
    @default_username = data[:user]
  end

  def token
    {
      :cookies => @auth_cookies,
      :user => @default_username
    }.to_yaml
  end

  def login(email, password)
    response = Faraday.post AUTH_ENDPOINT, extra_login_params.merge('username' => email, 'password' => password)
    success = (response.headers['location'] =~ /me\.com\/gallery/i) && (response.status = 302)
    raise MobilemeError.new(401, 'Invalid credentials') unless success
    @default_username = email.split('@').first
    @auth_cookies = parse_cookies(response.headers['set-cookie'])

    response = Faraday.get "https://www.me.com/ro/" do |req|
      req.params = {'protocol' => 'roap', 'item' => 'properties', 'mode' => 'find', 'depth' => '1'}
      req.headers['Cookie'] = cookies_as_string
    end
    new_cookies = parse_cookies(response.headers['set-cookie'])
    @auth_cookies.merge!(new_cookies)
  end

  def logout
    @default_username = nil
    @auth_cookies = nil
  end

  def get_albums_list(options = {})
    request(:get, API_ENDPOINT % [@default_username], :depth => 1).reject do |e|
      e['type'] == 'Movie'
    end
  end

  def get_album_contents(album_id, options = {})
    request(:get, "#{API_ENDPOINT % [@default_username]}/#{album_id}", :depth => 'album').reject do |e|
      e['type'] == 'Movie'
    end
  end

  def cookies_as_string
    @auth_cookies.map{|k,v| "#{k}=#{v}" }.join('; ')
  end

protected
  def parse_cookies(set_cookie_header)
    set_cookie_header.scan(/([a-z0-9\-_\.]+)=([a-z0-9=:]+);/i).inject({}) do |hsh, kuk|
      hsh[kuk[0]] = kuk[1]
      hsh
    end
  end

  def extra_login_params
    {
      'service' => 'gallery',
      'ssoNamespace' => 'appleid',
      'returnURL' => 'aHR0cHM6Ly93d3cubWUuY29tL2dhbGxlcnkv',
      'cancelURL' => 'http://www.me.com/mail',
      '{SSO_ATTRIBUTE_NAME}' => '{SSO_ATTRIBUTE_VALUE}',
      'ssoOpaqueToken' => '',
      'ownerPrsId' => '',
      'formID' => 'loginForm',
      'keepLoggedIn' =>'true'
    }
  end

  def request(http_method, api_path, options = {})
    api_path = "#{api_path}?webdav-method=truthget&feedfmt=galleryowner&depth=1&synchronize=true&lang=en"

    conn = Faraday::Connection.new(:url => api_path) do |builder|
      #builder.use Faraday::Request::UrlEncoded
      #builder.use Faraday::Response::ParseJson
      builder.use Faraday::Adapter::NetHttp
    end

    response = conn.send(http_method) do |req|
      req.params = options.merge(default_options)
      req.headers['Cookie'] = cookies_as_string
      req.headers['X-Mobileme-Isc'] = @auth_cookies['isc-www.me.com']
      req.headers['X-Mobileme-Version'] = '1.0'
      req.headers['X-Prototype-Version'] = '1.0.3'
      req.headers['X-Requested-With'] = "XMLHttpRequest"
    end

    Rails.logger.debug("mobileme response headers for #{api_path}: #{response.headers.inspect}")
    Rails.logger.debug("mobileme response body for #{api_path}: #{response.body}")

    raise MobilemeError.new(403, response.body) if response.body =~ /Error:/
    #begin
      json_response = MultiJson.decode(response.body)



    #rescue MultiJson::DecodeError => de
    #  raise MobilemeError.new(401, response.body)
    #end
    mash_response = Hashie::Mash.new(json_response)
    #TODO Handle unsuccessful response
    mash_response.records
  end

  def default_options
    {
      'webdav-method' => 'truthget',
      'feedfmt' => 'galleryowner',
      'synchronize' => 'true',
      'lang' => 'en'
      #'depth' => 1
    }
  end


end
