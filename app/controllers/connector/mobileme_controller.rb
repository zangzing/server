require 'addressable/uri'


class Connector::MobilemeController < Connector::ConnectorController

  def self.api_from_identity(identity)
    cookies = identity.credentials
    MobilemeConnector.new(cookies)
  end

  def self.get_fresh_headers(photo, source_url)
    user = User.find(photo.user_id)
    identity = user.identity_for_mobileme
    if identity
      api = api_from_identity(identity)
      api.refresh_auth_cookies
      return {'Cookie' => api.cookies_as_string}
    end
  end


  # we have seen lots of cases there the mobileme json returns a valid looking url for the 'large' format
  # that returns 404 error. in these cases, we can only degrade to the 'web' format.
  # we do the check in this callback because we want it to run in the GeneralImportRequest worker
  # and not the ConnectorWorker that the user is waiting on
  def self.get_downloadable_photo_url(photo, source_url)


    # we switched to the addressable gem because it does a better job
    # parsing urls than the built in URI module
    uri = Addressable::URI::parse(source_url)

    # addressable gem doesn't seem to always set port correctly for https urls
    # so check and set if necessary
    port = uri.port
    if uri.scheme == 'https' && port.nil?
      port = 443
    end

    http = Net::HTTP.new(uri.host, port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    http.request_head(uri.request_uri) do |response|
        if response.code == "404"
          web_url = source_url.gsub('/large.', '/web.')
          return web_url
        end
    end

    return source_url
  end



  def self.moderate_exception(exception)
    return exception
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

  def self.get_photo_url(photo_info, size, password_protected = false)
    case size
      when :thumb then
        return convert_to_public_url(photo_info.smallDerivativeUrl)

      when :screen then
        return convert_to_public_url(photo_info.webImageUrl)

      when :full then

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

        if(photo_info.largeImagePath && !photo_info.largeImagePath.blank? && photo_info.largeImageUrl  && !photo_info.largeImageUrl.blank? )
          full_url = photo_info.largeImageUrl
        else
          full_url = photo_info.webImageUrl
        end

        # we have seen a bunch of problem with the 'ro' url and only need it if the album is password protected
        # so convert to the public url if we can
        if !password_protected
          full_url = convert_to_public_url(full_url)
        end

        return full_url

      else
        raise "invalid size param: #{size}"
    end
  end

  def self.convert_to_public_url(url)
    return url.gsub('https://www.me.com/ro', 'http://gallery.me.com').gsub('/Galleries/', '/')
  end

end
