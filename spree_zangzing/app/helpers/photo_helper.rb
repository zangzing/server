module PhotoHelper

  def framed_photo_tag( photo, targetw, targeth )

    scale  = [ targetw / photo.width.to_f, targeth / photo.height.to_f].min
    width  = (photo.width * scale).floor
    height = (photo.height * scale).floor

    raw "<div class=\"selected-photo\">" +
    "  <div class=\"photo-border\">" +
    "    <img class=\"photo-image\" src=\"#{ssl_url( photo.thumb_url )}\" style=\" width: #{width}px; height: #{height}px\">"+
    #"    <div class=\"photo-delete-button\"></div>"+
    "    <img class=\"bottom-shadow\" src=\"/images/photo/bottom-full.png?1\" >"+
    "  </div>"+
    "</div>"
  end

  def ssl_url( url )
    if url =~ /^https:.*/
      url
    else
      if url =~ /http:\/\/.+zz.s3.amazonaws.com.*$/
        url.match(/^http:\/\/(.*).s3.amazonaws.com(.*)$/)
        "https://s3.amazonaws.com/#{$1}#{$2}"
      else
        url.gsub(/^http:/,'https:')
      end
    end
  end

end