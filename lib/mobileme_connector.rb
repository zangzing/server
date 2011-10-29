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
  
  AUTH_ENDPOINT = 'https://auth.me.com/authenticate'
  API_ENDPOINT = 'https://www.me.com/ro/%s/Galleries' #?webdav-method=truthget&feedfmt=galleryowner&depth=1&synchronize=true&lang=en

  attr_accessor :default_username, :auth_cookies

  def initialize(auth_cookies = nil)
    @auth_cookies = auth_cookies
  end

  def login(email, password)
    email = 	'alvarezm50@me.com'
    password = 'Share1001photos'
    entry_page = self.class.get(AUTH_ENDPOINT,
    :headers => {
        'Cookie' => 'mmls=1; lua=1',
        'Host' => 'auth.me.com',
        'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3',
        'Connection' => 'keep-alive',
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'en-us;q=0.7,en;q=0.3',
        'Accept-Charset' => '	windows-1251,utf-8;q=0.7,*;q=0.7'
    })

    doc = Nokogiri::HTML(entry_page.body)
    @login_params = {}
    doc.xpath('//form[@name="loginForm"]/input[@type="hidden"]').each do |hidden_field|
      @login_params[hidden_field["name"]]=hidden_field['value']
    end
    @login_params['ssoNamespace']='appleid'
    begin
    response = self.class.post(AUTH_ENDPOINT,
      :headers => {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Referer' => AUTH_ENDPOINT,
        'Cookie' => 'mmls=1; lua=1',
        'Host' => 'auth.me.com',
        'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3',
        'Connection' => 'keep-alive',
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'en-us;q=0.7,en;q=0.3',
        'Accept-Charset' => '	windows-1251,utf-8;q=0.7,*;q=0.7'
      },
      :body => @login_params.merge('username' => email, 'password' => password) #extra_login_params
#:body => 'cancelURL=http%3A%2F%2Fwww.me.com%2Fmail&formID=loginForm&mailstatus=&ownerPrsId=&password=Share1001photos&returnURL=aHR0cHM6Ly93d3cubWUuY29tL2dhbGxlcnkv&service=mail&ssoNamespace=appleid&ssoOpaqueToken=&username=alvarezm50%40me.com'
    )
    rescue Exception => e
      puts e  #Breakpoint here!
      raise e
    end
    success = (response.body =~ /src="\/my\/core_gallery/i) && (response.code = 302)
    if success
      @default_username = email.split('@').first
      @auth_cookies = response.cookies
    end
    raise MobilemeError.new(401, 'Invalid credentials') unless success
  end

  def logout
    @default_username = nil
    @auth_cookies = nil
  end

  def get_albums_list(options = {})
    request(:get, API_ENDPOINT % [@default_username], :depth => 1).reject do |e|
      e.type == 'Movie'
    end
  end

  def get_album_contents(album_id, options = {})
    request(:get, "#{API_ENDPOINT % [@default_username]}/#{album_id}", :depth => 'album').reject do |e|
      e.type == 'Movie'
    end
  end

protected
  def extra_login_params
    {
      'service' => 'gallery',
      'returnURL' => 'aHR0cHM6Ly93d3cubWUuY29tL2dhbGxlcnkv',
      'cancelURL' => 'http://www.me.com/mail',
      'mailstatus' => '',
      'ssoNamespace' => 'appleid',
      'ssoOpaqueToken' => '',
      'ownerPrsId' => '',
      'formID' => 'loginForm'
      #'username' => sdfsdfsd@me.com
      #'password' => sdfsdf
    }
  end

  def request(http_method, api_path, options = {})
    response = self.class.send(http_method, api_path, :query => options.merge(default_options))
    raise MobilemeError.new(401, response.body.to_s) if response.body =~ /Error:/
    mash_response = Hashie::Mash.new(response)
    #TODO Handle unsuccessful response
    mash_response.records
  end

  def default_options
    {
      'webdav-method' => 'truthget',
      'feedfmt' => 'galleryowner'
      #'depth' => 1
    }
  end


end
