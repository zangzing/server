class KodakError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end


class KodakConnector
  require 'open-uri'

  REST_API_URL = 'http://www.kodakgallery.com/site/rest/v1.0'

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

  def user_ssid
    @user_ssid ||= get_user_ssid
  end

  #Low-level calls
  def get_user_ssid
    homepage_uri = URI.parse("http://www.kodakgallery.com/gallery/creativeapps/photoPicker/albums.jsp")
    http = Net::HTTP.new(homepage_uri.host, homepage_uri.port)
    request = Net::HTTP::Get.new(homepage_uri.request_uri, {'cookie' => @auth_cookies})
    begin
      response = http.request(request)
    rescue
      raise HttpCallFail
    end
    raise KodakError.new(response.code, response.message) if response.code != '200'
    response.body =~ /esg\.ident\.model\.ssId = '(\d{4,})';/ ? $1 : nil
  end

  def send_request(url)
    service_uri = URI.parse("#{REST_API_URL}#{url}")
    http = Net::HTTP.new(service_uri.host, service_uri.port)
    request = Net::HTTP::Get.new(service_uri.request_uri, {'cookie' => @auth_cookies})
    begin
      response = http.request(request)
    rescue => exception
      raise HttpCallFail
    end
    raise KodakError.new(response.code, response.message) if response.code != '200'
    Hash.from_xml(response.body).values.first
  end

  def proxy_response(url)
    bin_io = OpenURI.send(:open, url, compose_request_header)
    bin_io.read
  end
  
  def compose_request_header
    {
      'Host' => 'www.kodakgallery.com',
      'Cookie' => @auth_cookies
    }
  end

  #Static stuff
  def self.verify_cookie_as_authenticated(cookie_string)
    #EK_S and EK_E (and possibly sourceId) are names of real cookies which indicates we're authenticated
    cookie_string && cookie_string.include?('EK_S') && cookie_string.include?('EK_E') && cookie_string.include?('sourceId')
  end

end