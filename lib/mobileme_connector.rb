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
    request(:get, API_ENDPOINT % [@default_username], :depth => 1)
  end

  def get_album_contents(album_id, options = {})
    request(:get, "#{API_ENDPOINT % [@default_username]}/#{album_id}", :depth => 'album')
  end

  def cookies_as_string(cookie_hash = nil)
    (cookie_hash || @auth_cookies).map{|k,v| "#{k}=#{v}" }.join('; ')
  end

  def refresh_auth_cookies
    auth_only_cookies = @auth_cookies.select{|k,_| %w(lua mmls).include?(k) || (k =~ /^mmp-/i) }.to_hash
    response = Faraday.get AUTH_ENDPOINT do |req|
      req.params = extra_login_params.merge('anchor' => 'home')
      req.headers['Cookie'] = cookies_as_string(auth_only_cookies)
    end
    new_cookies = parse_cookies(response.headers['set-cookie'])
    @auth_cookies.merge!(new_cookies)
  end

protected
  def parse_cookies(set_cookie_header)
    return {} unless set_cookie_header
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
      builder.use Faraday::Adapter::NetHttp
    end

    refresh_auth_cookies
    response = conn.send(http_method) do |req|
      req.params = options.merge(default_options)
      req.headers['Cookie'] = cookies_as_string
      req.headers['X-Mobileme-Isc'] = @auth_cookies['isc-www.me.com']
      req.headers['X-Mobileme-Version'] = '1.0'
      req.headers['X-Prototype-Version'] = '1.6.0.3'
      req.headers['X-Requested-With'] = "XMLHttpRequest"
      req.headers['Referer'] = "https://www.me.com/gallery/"
      req.headers['Connection'] = "keep-alive"
      req.headers['Accept'] = "text/javascript, text/html, application/xml, text/xml, */*"
      req.headers['Host'] = "www.me.com"
    end

    # this clears the cookie and won't retry
    raise InvalidToken.new(response.body) if response.status == 401

    # this won't clear cookies and won't retry
    raise MobilemeError.new(response.status, response.body) if response.status != 200

    begin
      LogEntry.create(:source_id=>0, :source_type=>"MobileMeConnector", :details=>"#{api_path} \n\n #{response.headers.inspect} \n\n #{response.body}")
    rescue Exception => ex
      # we have seen some errors here if the text is large than the
      # mysql max packet size
      Rails.logger.info small_back_trace(ex)
    end



    json_response = MultiJson.decode(response.body)

    mash_response = Hashie::Mash.new(json_response)

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
