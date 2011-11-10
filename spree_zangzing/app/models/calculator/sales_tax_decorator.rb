Calculator::SalesTax.class_eval do

  # get the original update! method before we redefine it
  @@original_compute ||= instance_method('compute')

  # add support for option to skip tax since it is
  # done multiple times and we only need it the last time
  def compute(order)
    options = Order.thread_options
    if options[:skip_tax]
      0.0
    else
      #@@original_compute.bind(self).call(order)
      # this is a bit of a cheat but we are going with the assumption that
      # all items have the same tax rate - this is a very large win performance
      # wise when you have a large number of line items
      rate = self.calculable
      order.line_items.inject(0) {|sum, line_item|
        sum += line_item.total * rate.amount
      }
    end
  end
end
