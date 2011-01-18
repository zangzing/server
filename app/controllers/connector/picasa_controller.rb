class Connector::PicasaController < Connector::GoogleController

protected

  def service_identity
    @service_identity ||= current_user.identity_for_picasa
  end

  def client
    @picasa_client ||= GData::Client::Photos.new
  end

  def scope
    'https://picasaweb.google.com/data/feed/'
  end

protected
  def get_photo_url(media_group, size)
    if size == :full || size == :screen
      make_plain_http(media_group.elements['media:content'].attributes['url'])
    elsif size == :thumb
      thumbnails = []
      media_group.elements.each('media:thumbnail') do |thumb|
        thumbnails << {:url => thumb.attributes['url'], :width => thumb.attributes['width'].to_i, :height => thumb.attributes['height'].to_i}
      end
      thumbnails.sort_by {|thumb| thumb[:height]*thumb[:width] }
      make_plain_http(thumbnails.last[:url])
    end
  end

  def make_source_guid(media_element)
    "picasa_"+Photo.generate_source_guid(get_photo_url(media_element, :full))
  end

  # take a potentially https url and make it http
  def make_plain_http(url)
    converted =  url.gsub(/^https:\/\//, 'http://')
    if converted.nil?
      return url
    else
      return converted
    end
  end
end
