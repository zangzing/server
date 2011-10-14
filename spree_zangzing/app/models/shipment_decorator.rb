Shipment.class_eval do
  has_many :line_items

  def after_ship
    ZZ::Async::Email.enqueue( :order_shipped, self.id )
  end

  def tracking_number
      carrier,number = tracking.split('::')
      number
  end

  def tracking_carrier
      carrier,number = tracking.split('::')
      carrier
  end


end

