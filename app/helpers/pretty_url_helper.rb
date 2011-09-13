module PrettyUrlHelper
  def album_pretty_path(username, friendly_id)
    return "/#{username}/#{friendly_id}"
  end

  # build the fully qualified url with scheme, host, uri
  def build_full_path(path, secure = false)
    scheme = secure ? "https://" : "http://"
    full_path = "#{scheme}#{Server::Application.config.application_host}#{path}"
  end

  def album_pretty_url(album, friendly_id = nil)
    friendly_id = friendly_id.nil? ? album.friendly_id : friendly_id
    return "http://#{Server::Application.config.application_host}#{album_pretty_path(album.user.username, friendly_id)}"
  end

  def album_activities_pretty_url( album )
    "#{album_pretty_url( album )}/activities"
  end

  def album_people_pretty_url( album )
    "#{album_pretty_url( album )}/people"
  end

  def photo_pretty_url(photo)
    "#{user_url( photo.album.user)}/#{photo.album.friendly_id}/photos/#!#{photo.id}"
  end

  def photo_url_with_comments(photo)
    "#{user_url( photo.album.user)}/#{photo.album.friendly_id}/photos/#{photo.id}?show_comments=true"
  end

  def photo_url(photo)
    album_photos(photo.album) + "/#!{photo.id}"
  end

  def user_pretty_url(user)
    user_url( user )
  end

  def user_activities_pretty_url(user)
    return "#{user_pretty_url(user)}/activities"
  end

  def user_people_pretty_url(user)
    return "#{user_pretty_url(user)}/people"
  end

  def potd_path
    return '/zangzing/zangzing-photo-of-the-day'
  end

  def mobile_album_json_path(album_id, cache_ver)
    return "/mobile/albums/#{album_id}/photos_json?#{cache_ver}"
  end

  def bitly_url(url)
    begin
      bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key]).shorten(url)
      return bitly.short_url
    rescue Exception => e
      Rails.logger.error e
      Rails.logger.error e.backtrace
      return url
    end
  end

  def join_pretty_url( return_to=nil, email=nil )
    url = []
    url << join_url
    query = []
    query << "return_to=#{return_to}" if return_to
    query << "email=#{email}" if email
    query = query.join('&')
    url << query
    url = url.join('?')
    URI::escape(url)
  end

end