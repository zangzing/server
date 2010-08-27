class TwitterError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end

class TwitterConnector
  require 'twitter_oauth'

  def initialize(token = nil)
    self.access_token = token
  end

  def access_token
    [@access_token_token, @access_token_secret].join('_')
  end

  def access_token=(token)
    if token.kind_of?(String) && token.include?('_')
      @access_token_token, @access_token_secret = token.split('_')
      create_client!
    end
  end

  def consumer
    @consumer ||= create_consumer
  end

  def create_consumer
    TwitterOAuth::Client.new(
        :consumer_key => TwitterConnector.api_key,
        :consumer_secret => TwitterConnector.shared_secret
    )
  end

  def create_access_token!(oauth_token, request_token_secret, oauth_verifier)
    oauth_access_token = consumer.authorize(
      oauth_token,
      request_token_secret,
      :oauth_verifier => oauth_verifier
    )
    @access_token_token = oauth_access_token.token
    @access_token_secret = oauth_access_token.secret
  end

  def client
    @client
  end

protected

  def create_client!
    return unless @access_token_token || @access_token_secret
    @client = TwitterOAuth::Client.new(
      :consumer_key => TwitterConnector.api_key,
      :consumer_secret => TwitterConnector.shared_secret,
      :token => @access_token_token,
      :secret => @access_token_secret
    )
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