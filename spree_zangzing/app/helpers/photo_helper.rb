module PhotoHelper

  STACK_ANGLES=[['-8', '-4'],['-4', '4'],['8', '4'] ]

  def framed_photo_tag( photo, targetw, targeth )

    scale  = [ targetw / photo.rotated_width.to_f, targeth / photo.rotated_height.to_f].min
    width  = (photo.rotated_width * scale).floor
    height = (photo.rotated_height * scale).floor

    raw "<div class=\"selected-photo\">" +
    "  <div class=\"photo-border\">" +
    "    <img class=\"photo-image\" src=\"#{ssl_url( photo.thumb_url )}\" style=\" width: #{width}px; height: #{height}px\">"+
    "    <img class=\"bottom-shadow\" src=\"/images/photo/bottom-full.png?1\" style=\"width: #{width+14}px\">"+
    "  </div>"+
    "</div>"
  end

  def stacked_photo_tag( photo, targetw, targeth )

    scale  = [ targetw / photo.width.to_f, targeth / photo.height.to_f].min
    width  = (photo.width * scale).floor
    height = (photo.height * scale).floor

    fheight= height+10
    fwidth = width+10
    rotation = rand( STACK_ANGLES.length )
    left = (172/2)-(fwidth/2)
    top  = (118/2)-(fheight/2)
    
    raw '<div class="picon" style="left:'+left.to_s+'px; top:'+top.to_s+'px;">' +
        '   <div class="stacked-image" style="-moz-transform: rotate('+STACK_ANGLES[rotation][0]+'deg); -webkit-transform: rotate('+STACK_ANGLES[rotation][0]+'deg); height: '+fheight.to_s+'px; width: '+fwidth.to_s+'px;"></div>'+
        '   <div class="stacked-image" style="-moz-transform: rotate('+STACK_ANGLES[rotation][1]+'deg); -webkit-transform: rotate('+STACK_ANGLES[rotation][1]+'deg); height: '+fheight.to_s+'px; width: '+fwidth.to_s+'px;"></div>'+
        '   <div class="stacked-image" style="height: '+fheight.to_s+'px; width: '+fwidth.to_s+'px;">'+
        '     <img class="cover-photo" src="'+ssl_url( photo.thumb_url )+'" style="height: '+height.to_s+'px; width: '+width.to_s+'px;">'+
        '   </div>'+
        '</div>'
  end



  # Remove the protocol so the photo picks up
  # whatever the protocol from the requesting page is.
  # We also rejigger the s3 url to use s3.amazonaws.com which does have a
  # ssl certificate
  def ssl_url( url )
    if url =~ /^https:.*/
      url
    else
      if url =~ /http:\/\/.+zz.s3.amazonaws.com.*$/
        url.match(/^http:\/\/(.*).s3.amazonaws.com(.*)$/)
        "//s3.amazonaws.com/#{$1}#{$2}"
      else
        url.gsub(/^http:/,'https:')
      end
    end
  end

end