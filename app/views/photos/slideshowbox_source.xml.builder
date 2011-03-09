xml.instruct!
xml.SlideshowBox do
  xml.items do
    @photos.each do |photo|
      xml.item do

          #todo:does this proxy stuff work?
          xml.thumbnailPath photo.thumb_url.include?('/service/proxy?') ? photo.thumb_url : "#{proxy_path}?url=#{photo.thumb_url}"
          xml.largeImagePath photo.screen_url.include?('/service/proxy?') ? photo.screen_url : "#{proxy_path}?url=#{photo.screen_url}"
          xml.fullScreenImagePath photo.screen_url.include?('/service/proxy?') ? photo.screen_url : "#{proxy_path}?url=#{photo.screen_url}"
        

        xml.title photo.caption
        xml.description photo.caption
      end
    end
  end
end
