module TrackingHelper
#This helper take a carrier::number combo from
# commerce shipping
  def tracking_info_url( carrier,tracking )
    carrier.upcase!
    tracking.upcase!
    case( carrier )
      when 'UPS':
        return "http://wwwapps.ups.com/WebTracking/processInputRequest?tracknum=#{tracking}"
      when 'FEDEX':
        return "http://www.fedex.com/Tracking?tracknumber_list=#{tracking}"
      when 'USPS':
        return "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?origTrackNum=#{tracking}"
      else
        return nil
    end
  end

  def tracking_link( carrier_tracking_combo )
    return '' if carrier_tracking_combo.blank?
    carrier,tracking = carrier_tracking_combo.split('::')
    if carrier.present? && tracking.present?
      carrier.upcase!
      tracking.upcase!
      link_to( tracking, tracking_info_url( carrier, tracking), { :target => '_blank'} )
    else
      carrier_tracking_combo
    end
  end
end
