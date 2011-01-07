xml.instruct!
xml.SlideshowBox do
  xml.items do
    @photos.each do |photo|
      xml.item do

          #todo:does this proxy stuff work?
          xml.thumbnailPath photo.current_thumb_url.include?('/proxy?') ? photo.current_thumb_url : "/proxy?url=#{photo.current_thumb_url}"
          xml.largeImagePath photo.current_screen_url.include?('/proxy?') ? photo.current_screen_url : "/proxy?url=#{photo.current_screen_url}"
          xml.fullScreenImagePath photo.current_original_url.include?('/proxy?') ? photo.current_original_url : "/proxy?url=#{photo.photo.current_original}"
        

#        if(photo.state == 'ready')
#          xml.thumbnailPath photo.thumb_url.include?('/proxy?') ? photo.thumb_url : "/proxy?url=#{photo.thumb_url}"
#          xml.largeImagePath photo.medium_url.include?('/proxy?') ? photo.medium_url : "/proxy?url=#{photo.medium_url}"
#          xml.fullScreenImagePath photo.image.url.include?('/proxy?') ? photo.image.url : "/proxy?url=#{photo.image.url}"
#        else
#          xml.thumbnailPath photo.source_thumb_url.include?('/proxy?') ? photo.source_thumb_url : "/proxy?url=#{photo.source_thumb_url}"
#          xml.largeImagePath photo.source_screen_url.include?('/proxy?') ? photo.source_screen_url : "/proxy?url=#{photo.source_screen_url}"
#          xml.fullScreenImagePath photo.source_screen_url.include?('/proxy?') ? photo.source_screen_url : "/proxy?url=#{photo.source_screen_url}"
#        end
        xml.title photo.caption
        xml.description photo.caption
      end
    end
  end
end
