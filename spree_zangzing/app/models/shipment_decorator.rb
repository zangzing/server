Shipment.class_eval do
  has_many :line_items

  def after_ship
    ZZ::Async::Email.enqueue( :order_shipped, self.id )
  end

  def tracking_number
      if tracking
        carrier,number = tracking.split('::')
        return number
      else
        return nil
      end

  end

  def tracking_carrier
      if tracking
        carrier,number = tracking.split('::')
        return carrier
      else
        return nil
      end
  end

end

