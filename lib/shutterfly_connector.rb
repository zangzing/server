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

  cattr_accessor :app_id, :shared_secret

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
    sign_request(url, 'oflyuser/createToken.sfly', params_hash, true)
  end

  def call_api(call_path, method_params = {})
    should_be_signed = method_params.delete(:signed) || true
    request_url = "#{call_path}#{method_params.empty? ? '' : '?'}#{method_params.to_url_params}"
    request = Net::HTTP::Get.new(request_url)
    request = sign_request(request, call_path, method_params) if should_be_signed
    http = init_http_connection
    request['User-Agent'] = 'ZangZing Server'
    response = http.request(request)

    begin
      LogEntry.create(:source_id=>0, :source_type=>"ShutterflyConnector", :details=>"#{call_path} \n\n #{method_params.inspect} \n\n #{response.body}")
    rescue Exception => ex
      # we have seen some errors here if the text is large than the
      # mysql max packet size
      Rails.logger.info small_back_trace(ex)
    end


    raise ShutterflyError.new(response.code, response.body) if (400..501).include?(response.code.to_i)
    result = Hash.from_xml(response.body)
    normalize_response(extract_data(result))
  end


  #http://www.shutterfly.com/documentation/api_Album.sfly
  #http://www.shutterfly.com/documentation/howto_Album.sfly
  def get_albums
    data = call_api("/userid/#{userid_token}/album")
    albums = data[:entry] || []

    if !albums.kind_of?(Array)
      # if there is just one album in the account, then the
      # response is just a hash for that album
      # need to wrap it in an array
      albums = [albums]
    end

    return albums


  end

  def get_images(album_id)
    data = call_api("/userid/#{userid_token}/albumid/#{album_id}?category-type=image")

    images = data[:entry] || []

    if !images.kind_of?(Array)
      # if there is just one image in the ablum, then the
      # response is just a hash for that image
      # need to wrap it in an array
      images = [images]
    end
    
    return images
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
  def sign_request(request, call_path, params_hash, anonymous = false)
    ofly_timestamp = get_ofly_timestamp
    api_sig = calc_call_signature(call_path, params_hash, ofly_timestamp)
    sign_params = {
      'oflyTimestamp' => ofly_timestamp,
      'oflyApiSig' => api_sig,
      'oflyHashMeth' => HASH_METHOD
    }
    sign_params.merge!('oflyUserid' => userid_token) if userid_token and !anonymous
    if request.kind_of?(String)
      "#{request}#{request.include?('?') ? '&' : '?'}#{sign_params.to_url_params}"
    elsif request.kind_of?(Net::HTTPRequest)
      sign_params.merge!('X-OPENFLY-Authorization' => "SFLY user-auth=#{auth_token}") if auth_token and !anonymous
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
    else
      normalized_response = response
    end
    normalized_response
  end

  # Converts JSON-parsed hash keys and values into a Ruby-friendly format
  # Convert :id into integer and :updated_time into Time and all keys into symbols
  def normalize_hash(hash)
    normalized_hash = {}
    hash.each do |k, v|
      case k
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