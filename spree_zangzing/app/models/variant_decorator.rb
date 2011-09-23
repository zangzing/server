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

  def custom_image
    if images.count > 0
      images.first
    else
      product.custom_image
    end
  end

  def custom_description
      if images.count > 0
        images.first.description
      else
        product.description
      end
  end

end