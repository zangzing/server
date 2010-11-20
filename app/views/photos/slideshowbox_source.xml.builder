xml.instruct!
xml.SlideshowBox do
  xml.items do
    @photos.each do |photo|
      xml.item do
        if(photo.state == 'ready')
          xml.thumbnailPath "/proxy?url=#{photo.thumb_url}"
          xml.largeImagePath "/proxy?url=#{photo.medium_url}"
          xml.fullScreenImagePath "/proxy?url=#{photo.image.url}"
        else
          xml.thumbnailPath "/proxy?url=#{photo.source_thumb_url}"
          xml.largeImagePath "/proxy?url=#{photo.source_screen_url}"
          xml.fullScreenImagePath "/proxy?url=#{photo.source_screen_url}"
        end
        xml.title photo.caption
        xml.description photo.headline
      end
    end
  end
end
