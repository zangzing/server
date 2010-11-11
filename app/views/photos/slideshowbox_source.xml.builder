xml.instruct!
xml.SlideshowBox do
  xml.items do
    @photos.each do |photo|
      xml.item do
        xml.thumbnailPath "/proxy?url=#{photo.thumb_url}"
        xml.largeImagePath "/proxy?url=#{photo.medium_url}"
        xml.fullScreenImagePath "/proxy?url=#{photo.image.url}"
        xml.title photo.caption
        xml.description photo.headline
      end
    end
  end
end
