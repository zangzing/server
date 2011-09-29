class Calculator::EzpShipping < Calculator
  preference :ezp_shipping_type, :string, :default => ''
  preference :markup_amount, :decimal, :default => 0

  FIRST_CLASS ='FC'
  PRIORITY    ='PM'
  SECOND_DAY  ='SD'
  

  def self.description
    I18n.t("ezp_shipping_calculator")
  end

  def self.register
    super
    ShippingMethod.register_calculator(self)
  end

  def compute(object=nil)
    order = object if object.is_a? Order
    order = object.order if object.is_a? Shipment
    cost( order ) + preferred_markup_amount
  end

  def cost( order )
    ca =order.shipping_costs_array
    i = ca.index{ |x| x[:type] == preferred_ezp_shipping_type }
    service = ca[i]
    service[:price].to_f
  end

end
