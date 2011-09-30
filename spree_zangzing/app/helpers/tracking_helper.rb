module TrackingHelper
#This helper take a carrier::number combo from
# commerce shipping
  def tracking_url( carrier,tracking=nil )
    if tracking.nil?
     c,t = carrier.split('::')
     c.upcase!
     t.upcase!
    else
      c = carrier.upcase
      t = tracking.upcase
    end
    
    case( c )
      when 'UPS':
        return "http://wwwapps.ups.com/WebTracking/processInputRequest?tracknum=#{t}"
      when 'FEDEX':
        return "http://www.fedex.com/Tracking?tracknumber_list=#{t}"
      when 'USPS':
        return "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?origTrackNum=#{t}"
      else
        return ''
    end
  end

  def tracking_link( carrier_tracking_combo )
    return '' if carrier_tracking_combo.blank?
    carrier,tracking = carrier_tracking_combo.split('::')
    if carrier.present? && tracking.present?
      carrier.upcase!
      tracking.upcase!
      link_to( tracking, tracking_url( carrier, tracking), { :target => '_blank'} )
    else
      carrier_tracking_combo
    end
  end

  def ezp_tracking_url( ezp_reference_id )
    "http://tools-portal.ezpservices.com/orderList.aspx?search=#{ezp_reference_id}"
  end
  
  def ezp_tracking_link( ezp_reference_id )
    return '' if ezp_reference_id.blank?
    link_to( ezp_reference_id, ezp_tracking_url( ezp_reference_id ), { :target => '_blank'} )
  end

  def braintree_transaction_url( response_code )
    if Rails.env.photos_production?
      "https://www.braintreegateway.com/merchants/ppg8rg9ymsbzffzs/transactions/#{response_code}"
    else
      "https://sandbox.braintreegateway.com/merchants/ppg8rg9ymsbzffzs/transactions/#{response_code}"
    end
  end
end
