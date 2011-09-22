Variant.class_eval do
  include ActionView::Helpers::NumberHelper

  def as_json
    {
      :id => id,
      :sku => sku,
      :name => name,
      :price => number_to_currency( price ),
      :values => option_values.collect { | ov | ov.as_json }
    }
  end
end