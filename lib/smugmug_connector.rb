class SmugmugError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end

class SmugmugConnector
  require 'oauth/consumer'

  API_ENDPOINT = '/services/api/json/1.2.2/'

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
    OAuth::Consumer.new(SmugmugConnector.api_key, SmugmugConnector.shared_secret,
                                   :site => "http://api.smugmug.com",
                                   :request_token_path => "/services/oauth/getRequestToken.mg",
                                   :authorize_path => "/services/oauth/authorize.mg",
                                   :access_token_path => "/services/oauth/getAccessToken.mg",
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
      'Access' => options[:access] || :Public,
      'Permissions' => options[:permissions] || :Read,
      'oauth_token_secret' => request_token.secret
    }
    "#{request_token.authorize_url}&#{auth_params.to_url_params}"
  end

  def call_method(method_name, method_params = {})
    api_query = method_params.merge(:method => method_name)
    raise SmugmugError.new(36, "An access token in needed") unless @access_token
    response = @access_token.get "#{API_ENDPOINT}?#{api_query.to_url_params}"
    result = JSON.parse(response.body)
    #{"stat":"ok","method":"smugmug.albums.get","Albums":[{"id":5298215,"Key":"9VoYf","Category":{"id":33,"Name":"Vacation"},"Title":"Fabulous me!"}]}
    #{"stat":"fail","method":"smugmug.albums.get","code":36,"message":"invalid/expired token"}
    stat = result.delete('stat')
    result.delete('method')
    raise SmugmugError.new(result['code'], result['message']) if stat == 'fail'
    normalize_response(extract_data(result))
  end

protected

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

  class << self
    attr_accessor :api_key, :shared_secret
  end

end