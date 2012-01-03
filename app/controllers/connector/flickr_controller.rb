class Connector::FlickrController < Connector::ConnectorController

  PHOTO_SIZES = {:thumb => 'Medium', :screen => 'zBig', :full => 'Big'}
  MY_STREAM_PER_PAGE = 100
  PHOTOSET_PAGE_SIZE = 250
  
  def self.api_from_identity(identity)
    flickr_token = identity.credentials
    #flickr.auth.checkToken :auth_token => flickr_token
    FlickRaw::Flickr.new(flickr_token)
  end

  def self.moderate_exception(exception)
    if exception.kind_of?(FlickRaw::FailedResponse) && exception.message =~ /invalid[\w\s]+token/i
      InvalidToken.new('OAuth token invalid')
    end
  end


protected



  def service_login_required
    unless flickr_auth_token
      self.class.call_with_error_adapter do
        @flickr_token = service_identity.credentials
        SystemTimer.timeout_after(http_timeout) do
          @flickr_auth = flickr.auth.checkToken :auth_token => flickr_auth_token
        end
      end
    end
  end

  def service_identity
    @service_identity ||= current_user.identity_for_flickr
  end

  def flickr_api
    @flickr_api ||= FlickRaw::Flickr.new(flickr_auth_token)
  end

  def flickr_api=(val)
    @flickr_api = val
  end


  def flickr_auth_token
    @flickr_token
  end

  def self.get_photo_url(photo_info, size_wanted = :screen)
    sz = {}
    if photo_info.flickr_type == 'sizes' then
      photo_info.size.each{|item| sz[item['label'].downcase.to_sym] = item['source'] if item['label'] =~ /^\w+$/  }
      unless sz[:large]
        biggest = photo_info.size.sort_by{ |p| p['width'].to_i * p['height'].to_i }.last
        sz[:large] = biggest['source']
      end
    else
      sz[:small] = photo_info.url_m if photo_info.respond_to?(:url_m)
      sz[:medium] = photo_info.url_z if photo_info.respond_to?(:url_z)
      sz[:large] = photo_info.url_l if photo_info.respond_to?(:url_l)
      sz[:original] = photo_info.url_o if photo_info.respond_to?(:url_o)
    end

    url = case size_wanted
      when :thumb  then sz[:small]    || sz[:medium]
      when :screen then sz[:large]    || sz[:medium] || sz[:small]
      when :full   then sz[:original] || sz[:large]  || sz[:medium] || sz[:small]
      else nil
    end

=begin
    unless url #Old way we was getting the url
      extension = 'jpg'
      size_letter = PHOTO_SIZES[size_wanted][0,1].downcase
      secret = photo_info.secret
      if size_wanted == :full && photo_info.respond_to?(:originalsecret) #If we've working with a Pro account
        extension = photo_info.originalformat
        size_letter = 'o'
        secret = photo_info.originalsecret
      end
      url = 'http://farm%s.static.flickr.com/%s/%s_%s_%s.%s' % [photo_info.farm, photo_info.server, photo_info.id, secret, size_letter, extension]
    end
=end
    url || ''
  end

  def self.make_source_guid(photo_info)
    "flickr_"+Photo.generate_source_guid(get_photo_url(photo_info, :full))
  end

end
