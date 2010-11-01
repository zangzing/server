class PhotobucketError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end

class PhotobucketConnector
  require 'oauth/consumer'
  cattr_accessor :consumer_key, :consumer_secret

  API_SITE = 'http://api.photobucket.com'
  TOKEN_DIVIDER = '<//>'

  def initialize(token = nil)
    self.access_token = token
  end

  def access_token(as_string = false)
    unless as_string
      @access_token
    else
      [@access_token.token, @access_token.secret].join(TOKEN_DIVIDER)
    end
  end

  def access_token=(token)
    if token.kind_of?(String) && token.include?(TOKEN_DIVIDER)
      parts = token.split(TOKEN_DIVIDER)
      create_access_token!(parts[0], parts[1])
    elsif
      @access_token = token
    end
  end

  def consumer
    @consumer ||= OAuth::Consumer.new(PhotobucketConnector.consumer_key, PhotobucketConnector.consumer_secret, 
      {
        :site => API_SITE,
        :request_token_url => "http://api.photobucket.com/login/request",
        :access_token_url => "http://api.photobucket.com/login/access",
        :authorize_url => "http://photobucket.com/apilogin/login",
        :http_method => :post,
        :scheme => :query_string
      })
  end

  def create_access_token!(oauth_token, oauth_token_secret, first_time = false)
    if first_time
      req_token = OAuth::RequestToken.from_hash(consumer, {:oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret})
      begin
        @access_token = req_token.get_access_token
      rescue => e
        if e.kind_of?(OAuth::Unauthorized)
          code, msg = e.message.split(' ')
          raise SmugmugError.new(code, "#{msg} (invalid/expired oauth request token)")
        end
      end
    elsif
      @access_token = OAuth::AccessToken.from_hash(consumer, {:oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret})
      refresh_owner_info!
    end
  end

  def get_authorize_url(request_token)
    request_token.authorize_url(:extra => request_token.secret)
  end
  
  def owner_info
    @owner
  end
  
  def refresh_owner_info!
    data = call_method('/user/-/url')
    @owner = {
      :username => data[:username].first,
      :album_subdomain => data[:subdomain].first[:album].first,
      :image_subdomain => data[:subdomain].first[:image].first,
      :api_subdomain => data[:subdomain].first[:api].first,
      :feed_subdomain => data[:subdomain].first[:feed].first,
      :user_path => data[:path].first
    }
  end

  def open_album(album_path = nil)
    path = CGI::escape([owner_info[:username], album_path].compact.join('/'))
    call_method("/album/#{path}", 'view' => 'flat', 'media' => 'images')
  end

 def call_method(method_name, method_params = {})
    query_params = method_params.merge('format' => 'xml')
    raise PhotobucketError.new(36, "An access token is needed") unless @access_token
    response = @access_token.get "#{method_name}?#{query_params.to_url_params}", query_params
    if response.code=='301' && response['location'] #PB API redirect
      response = Net::HTTP.get_response(URI.parse(response['location']))
    end
    result = XmlSimple.xml_in(response.body) #JSON.parse(response.body)
    stat = result['status'].first.downcase
    raise PhotobucketError.new(result['code'], result['message']) if stat == 'exception'
    normalize_response(extract_data(result['content']))
  end

protected

  def normalize_response(response)
   normalized_response = response
    case response
    when Hash
      normalized_response = normalize_hash(response)
    when Array
      normalized_response = normalize_array(response)
    end
    normalized_response
  end

  # Converts JSON-parsed hash keys and values into a Ruby-friendly format
  # Convert :id into integer and :updated_time into Time and all keys into symbols
  def normalize_hash(hash)
    normalized_hash = {}
    hash.each do |k, v|
      case k
#      when "error"
#        raise SmugmugError.new("#{v['type']} - #{v['message']}")
      when "id"
        if (v == v.to_i.to_s)
          normalized_hash[k.downcase.to_sym] = v.to_i
        else
          normalized_hash[k.downcase.to_sym] = v
        end
      when /_time$/
        normalized_hash[k.downcase.to_sym] = Time.parse(v)
      else
        data = extract_data(v)
        normalized_hash[k.downcase.to_sym] = case data
        when Hash
           normalize_hash(data)
        when Array
          normalize_array(data)
        else
          data
        end
      end
    end
    normalized_hash
  end

  def normalize_array(array)
    array.collect{ |item| normalize_response(item) }
  end

  # Extracts data from single key in Hash, if present
  def extract_data(object)
    if object.is_a?(Hash) && object.size == 1
      return object.values.first
#    elsif object.is_a?(Array) && object.size == 1
#      return object.first
    else
      return object
    end
  end

end