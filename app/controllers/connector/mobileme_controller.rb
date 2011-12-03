class Connector::MobilemeController < Connector::ConnectorController

  def self.api_from_identity(identity)
    cookies = identity.credentials
    MobilemeConnector.new(cookies)
  end

  def self.moderate_exception(exception)
    if exception.kind_of?(MobilemeError)
      InvalidToken.new(exception.reason)
    else
      nil
    end
  end

protected

  def connector
    @mobileme_connector ||= MobilemeConnector.new(service_identity.credentials)
  end


  def service_identity
    @service_identity ||= current_user.identity_for_mobileme
  end

  def self.make_source_guid(photo_info)
    "mobileme_"+Photo.generate_source_guid(photo_info.guid)
  end

  def self.get_photo_url(photo_info, size)
    url = case size
      when :thumb then photo_info.smallDerivativeUrl
      when :screen then photo_info.webImageUrl #mediumDerivativeUrl
      when :full then get_large_image_url( photo_info )
    end
    url.gsub!('https://www.me.com/ro', 'http://gallery.me.com').gsub!('/Galleries/', '/') if url && size!=:full
    url
  end
  
  def self.ping_url(url)
    !url.nil? && !url.blank?  #TODO implement ping_url
  end

  # when there is no large image the json looks like this
  #   "webImageUrl"    : "https://www.me.com/ro/niallaitken/Galleries/100080/DSCF0005/web.jpg",
  #   "webImagePath"   : "web.jpg",
  #   "largeImageUrl"  : "https://www.me.com/ro/Galleries/100080/DSCF0005/",
  #   "largeImagePath" :  "",
  # When There is a large image it looks like
  #   "webImageUrl"    : "https://www.me.com/ro/niallaitken/Galleries/100080/DSCF0005/web.jpg",
  #   "webImagePath"   : "web.jpg",
  #   "largeImageUrl"  : "https://www.me.com/ro/Galleries/1234/DSCF00005/large.jpg",
  #   "largeImagePath" : "large.jpg",
  def self.get_large_image_url(photo_info)
    if(  photo_info.largeImagePath && !photo_info.largeImagePath.blank?  &&
         photo_info.largeImageUrl  && !photo_info.largeImageUrl.blank? )
        return photo_info.largeImageUrl
    end
    return photo_info.webImageUrl
  end
end
