class Connector::PicasaController < Connector::GoogleController

protected

  def client
    @picasa_client ||= GData::Client::Photos.new
  end

protected
  def get_photo_url(media_group, size)
    if size == :full || size == :screen
      make_plain_http(media_group.at_xpath('m:content', NS)['url'])
    elsif size == :thumb
      thumbnails = []
      media_group.xpath('m:thumbnail', NS).each do |thumb|
        thumbnails << {:url => thumb['url'], :width => thumb['width'].to_i, :height => thumb['height'].to_i}
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
    converted = url.gsub(/^https:\/\//, 'http://')
    if converted.nil?
      return url
    else
      return converted
    end
  end
end
