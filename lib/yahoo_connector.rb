class YahooError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end

class YahooConnector
  require 'oauth/consumer'

  cattr_accessor :api_key, :shared_secret

  def initialize(token = nil)
    self.access_token = token
  end

  def access_token(as_string = false)
    unless as_string
      @access_token
    else
      [@access_token.token, @access_token.secret].join('_')
    end
  end

  def access_token=(token)
    if token.kind_of?(String) && token.include?('_')
      parts = token.split('_')
      create_access_token!(parts[0], parts[1])
    elsif
      @access_token = token
    end
  end

  def consumer
    @consumer ||= create_consumer
  end

  def create_consumer
    OAuth::Consumer.new(YahooConnector.api_key, YahooConnector.shared_secret,
                                   :site => "https://api.login.yahoo.com",
                                   :request_token_path => "/oauth/v2/get_request_token",
                                   :authorize_path => "/oauth/v2/request_auth",
                                   :access_token_path => "/oauth/v2/get_token",
                                   :http_method => :get,
                                   :scheme => :query_string
                                 )
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
    end
  end

  def get_authorize_url(request_token, options = {})
    auth_params = {
      'oauth_token_secret' => request_token.secret #,
      #:oauth_callback => options[:callback] || 'oob'
    }
    "#{request_token.authorize_url}&#{auth_params.to_url_params}"
    #request_token.authorize_url(auth_params)
  end

  def get_contacts(guid, parameters = {})
    call_method("http://social.yahooapis.com/v1/user/#{guid}/contacts", parameters)
  end

protected

  def call_method(url, method_params = {})
    api_query = method_params.merge(:method => method_name)
    raise SmugmugError.new(36, "An access token in needed") unless @access_token
    response = @access_token.get "#{url}?#{api_query.to_url_params}"
    result = JSON.parse(response.body)
#    raise SmugmugError.new(result['code'], result['message']) if stat == 'fail'
#    normalize_response(extract_data(result))
    result
  end

  def normalize_response(response)
   normalized_response = {}
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