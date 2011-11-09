Spree::BaseController.class_eval do
  # determine if we can return pre zipped data based on the
  # the client accept encodings
  def client_accepts_gzip?
    # now see if they accept gzip
    return false if request.accept_encoding.nil?
    encoding_types = request.accept_encoding.split(',')
    encoding_types.each do |type|
      return true if type.strip == 'gzip'
    end
    return false
  end


  # a helper to handle json return to client
  # if the data is compressed we determine if
  # the client can handle it, if so it is passed
  # on, otherwise we must decompress and then hand
  # it back
  def render_cached_json(json, public, compressed, cache_expires_in = 1.year)
    ver = params[:ver]
    if ver.nil? || ver == '0'
      # no cache
      expires_now
    else
      expires_in cache_expires_in, :public => public
    end
    if compressed
      # data is currently compressed see if client can handle it
      if client_accepts_gzip?
        # ok, client can take it as is
        response.headers['Content-Encoding'] = 'gzip'
      else
        # must deflate it and send plain
        Rails.logger.warn("render_cached_json had to convert compressed json to decompressed json since browser does not accept gzip encoding - user agent: #{request.user_agent} - accept_enconding: #{request.accept_encoding}")
        json = ActiveSupport::Gzip.decompress(json)
      end
    end
    render :json => json
  end

end
