class ShutterflyError < StandardError
  attr_accessor :code, :reason
  def initialize(error_code, error_reason)
    @code = error_code
    @reason = error_reason
    super("#{error_code} - #{error_reason}")
  end
end

class ShutterflyConnector
  require 'digest'

  class << self
    attr_accessor :app_id, :shared_secret
  end

  API_ENDPOINT = 'ws.shutterfly.com'
  HASH_METHOD = 'MD5'

  attr_accessor :userid_token, :auth_token

  def initialize(user_token = nil, authentication_token = nil)
    self.userid_token = user_token
    self.auth_token = authentication_token
  end

  #http://www.shutterfly.com/documentation/AuthAuth.sfly
  #http://www.shutterfly.com/documentation/SsiSetup.sfly
  def generate_authorization_url(opts = {})
    params_hash = {}
    params_hash.merge!('oflyRemoteUser' => opts[:remote_user]) if opts[:remote_user]
    params_hash.merge!('oflyCallbackUrl' => opts[:callback_url]) if opts[:callback_url]
    url = "http://www.shutterfly.com/oflyuser/createToken.sfly?#{params_hash.merge('oflyAppId' => ShutterflyConnector.app_id).to_url_params}"
    sign_request(url, 'oflyuser/createToken.sfly', params_hash)
  end

  def call_api(call_path, method_params = {})
    should_be_signed = method_params.delete(:signed) || true
    request_url = "#{call_path}#{method_params.empty? ? '' : '?'}#{method_params.to_url_params}"
    request = Net::HTTP::Get.new(request_url)
    request = sign_request(request, call_path, method_params) if should_be_signed
    http = init_http_connection
    request['User-Agent'] = 'ZZ Server (dev)'
    response = http.request(request)
    raise ShutterflyError.new(response.code, response.body) if (400..501).include?(response.code.to_i)
    result = XmlSimple.xml_in(response.body)
    normalize_response(extract_data(result))
  end


  #http://www.shutterfly.com/documentation/api_Album.sfly
  #http://www.shutterfly.com/documentation/howto_Album.sfly
  def get_albums
    data = call_api("/userid/#{userid_token}/album")
    data[:entry] || []
  end

  def get_images(album_id)
    data = call_api("/userid/#{userid_token}/albumid/#{album_id}?category-type=image")
    data[:entry] || []
  end

private

  def get_ofly_timestamp
    #The format is YYYY-MM-DDThh:mm:ss.sssTZD, where:
    #YYYY	=	four-digit year
    #MM	=	two-digit month	(01 through 12)
    #DD	=	two-digit day of month	(01 through 31)
    #hh	=	two-digit hour	(00 through 23; am/pm NOT allowed)
    #mm	=	two-digit minute	(00 through 59)
    #ss	=	two-digit second	(00 through 59)
    #sss	=	three-digit millisecond	(000 through 999)
    #TZD	=	time zone designator	(Z or +hh:mm or -hh:mm)
    DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.000%Z')
  end

  #http://www.shutterfly.com/documentation/OflyCallSignature.sfly
  def sign_request(request, call_path, params_hash)
    ofly_timestamp = get_ofly_timestamp
    api_sig = calc_call_signature(call_path, params_hash, ofly_timestamp)
    sign_params = {
      'oflyTimestamp' => ofly_timestamp,
      'oflyApiSig' => api_sig,
      'oflyHashMeth' => HASH_METHOD
    }
    sign_params.merge!('oflyUserid' => userid_token) if userid_token
    sign_params.merge!('X-OPENFLY-Authorization' => "SFLY user-auth=#{auth_token}") if auth_token
    if request.kind_of?(String)
      "#{request}#{request.include?('?') ? '&' : '?'}#{sign_params.to_url_params}"
    elsif request.kind_of?(Net::HTTPRequest)
      sign_params.each { |header, value| request[header] = value  }
      request
    end
  end

  def calc_call_signature(call_path, params_hash, ofly_timestamp)
    params_to_concat = params_hash.to_a.sort_by{ |e| e[0].downcase }.map { |p| "#{p[0]}=#{p[1]}"  }.join('&')
    call_signature_params = "oflyAppId=#{ShutterflyConnector.app_id}&oflyHashMeth=#{HASH_METHOD}&oflyTimestamp=#{ofly_timestamp}"
    concat_str = "#{ShutterflyConnector.shared_secret}#{call_path.first=='/' ? '' : '/'}#{call_path}?#{params_to_concat}&#{call_signature_params}"
    throw "Hash method #{HASH_METHOD} is not supperted by ShutterflyConnector" unless HASH_METHOD=='MD5'
    Digest::MD5.hexdigest(concat_str)
  end

protected

  def init_http_connection
    http = Net::HTTP.new(API_ENDPOINT, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
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
    else
      return object
    end
  end


end