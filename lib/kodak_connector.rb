class KodakConnector
  require 'open-uri'

  REST_API_URL = 'http://www.kodakgallery.com/site/rest/v1.0'

  cattr_accessor :http_timeout

  def initialize(token = nil)
    @auth_cookies = token
  end

  def auth_token
    @auth_cookies
  end

  def auth_token=(token)
    @auth_cookies = token if token && KodakConnector.verify_cookie_as_authenticated(token)
  end

  def sign_in(email, password)
    uri = URI.parse("http://www.kodakgallery.com/gallery/welcome.jsp")
    #First, retrieve a bunch of cookies for the session
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = http.open_timeout = KodakConnector.http_timeout
    response = http.get(uri.path)
    incomplete_cookies = response['set-cookie']
    login_data = CGI::escape("{\"email\":\"#{email}\",\"password\":\"#{password}\"}")
    incomplete_cookies += ", ssoCookies=#{login_data}; Path=/"
    #Call hidden login script
    randnum = rand(999999999).to_s.center(9, rand(9).to_s)
    login_uri = URI.parse("https://www.kodakgallery.com/gallery/account/login.jsp?&uid=#{randnum}")
    http = Net::HTTP.new(login_uri.host, login_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(login_uri.request_uri)
    request['cookie'] = incomplete_cookies
    response = http.request(request)

    complete_cookies = response.header['set-cookie']
    result = KodakConnector.verify_cookie_as_authenticated(complete_cookies)
    @auth_cookies = complete_cookies if result
    result
  end

  #Low-level calls

  def send_request(url)
    service_uri = URI.parse("#{REST_API_URL}#{url}")
    http = Net::HTTP.new(service_uri.host, service_uri.port)
    http.read_timeout = http.open_timeout = KodakConnector.http_timeout
    request = Net::HTTP::Get.new(service_uri.request_uri, {'cookie' => @auth_cookies})
    begin
      response = http.request(request)
    rescue => exception
      raise HttpCallFail
    end
    Hash.from_xml(response.body).values.first
  end

  def proxy_response(url)
    bin_io = OpenURI.send(:open, url, compose_request_header)
    bin_io.read
  end
  
  def response_as_file(url)
    RemoteFile.new(url, PhotoGenHelper.photo_upload_dir, compose_request_header)
  end

  #Static stuff
  def self.verify_cookie_as_authenticated(cookie_string)
    #EK_S and EK_E (and possibly sourceId) are names of real cookies which indicates we're authenticated
    cookie_string && cookie_string.include?('EK_S') && cookie_string.include?('EK_E') && cookie_string.include?('sourceId')
  end

protected

  def compose_request_header
    {
      'Host' => 'www.kodakgallery.com',
      'Cookie' => @auth_cookies
    }
  end

end