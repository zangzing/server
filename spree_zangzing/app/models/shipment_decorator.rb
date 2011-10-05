Shipment.class_eval do
  has_many :line_items

  def after_ship
    ZZ::Async::Email.enqueue( :order_shipped, self.id )
  end

end

