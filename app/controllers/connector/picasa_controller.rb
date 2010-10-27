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
    if size == :full
      media_group.elements['media:content'].attributes['url']
    else
      thumbnails = []
      media_group.elements.each('media:thumbnail') do |thumb|
        thumbnails << {:url => thumb.attributes['url'], :width => thumb.attributes['width'].to_i, :height => thumb.attributes['height'].to_i}
      end
      thumbnails.sort_by {|thumb| thumb[:height]*thumb[:width] }
      if size == :thumb
        thumbnails.first[:url]
      else #screen (largest of thumbnails)
        thumbnails.last[:url]
      end
    end
  end

end
