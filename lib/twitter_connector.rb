class TwitterError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end

class TwitterConnector
  require 'oauth/consumer'
  require 'twitter'

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
      @access_token = OAuth::AccessToken.from_hash(consumer, {:oauth_token => parts[0], :oauth_token_secret => parts[1]})
      #create_access_token!(parts[0], parts[1])
    elsif
      @access_token = token
    end
    create_client!
  end

  def consumer
    @consumer ||= create_consumer
  end

  def create_consumer
    OAuth::Consumer.new(TwitterConnector.api_key, TwitterConnector.shared_secret, {
      :site                 => 'http://twitter.com', #'http://api.twitter.com',
      :scheme               => :query_string,
      :http_method          => :get,
      :request_token_path   => '/oauth/request_token',
      :access_token_path    => '/oauth/access_token',
      :authorize_path       => '/oauth/authorize'
    })
  end

  def create_access_token!(oauth_token, first_time = false)
    if first_time
      req_token = OAuth::RequestToken.from_hash(consumer, :oauth_token => oauth_token)
      begin
        @access_token = req_token.get_access_token
      rescue => e
        if e.kind_of?(OAuth::Unauthorized)
          code, msg = e.message.split(' ')
          raise TwitterError.new(code, "#{msg} (invalid/expired oauth request token)")
        end
      end
    elsif
      @access_token = OAuth::AccessToken.from_hash(consumer, :oauth_token => oauth_token)
    end
    create_client!
  end

  def get_authorize_url(request_token, options = {})
    auth_params = {
      #'Access' => options[:access] || :Public,
      #'Permissions' => options[:permissions] || :Read,
      'oauth_token_secret' => request_token.secret
    }
    request_token.authorize_url(options.merge(auth_params))
  end

  def client
    @client
  end

protected

  def create_client!
    return unless @access_token
    oauth = Twitter::OAuth.new(TwitterConnector.api_key, TwitterConnector.shared_secret)
    oauth.authorize_from_access(@access_token.token, @access_token.secret)
    @client = Twitter::Base.new(oauth)
    @client.home_timeline(:count => 1) #Kinda ping
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
    else
      return object
    end
  end

  class << self
    attr_accessor :api_key, :shared_secret
  end

end