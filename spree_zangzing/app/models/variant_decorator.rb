Variant.class_eval do
  include ActionView::Helpers::NumberHelper

  def as_json
    {
      :id => id,
      :sku => sku,
      :price => number_to_currency( price ),
      #:description => custom_description,
      #:image_url => custom_image_url,
      :values => option_values.collect { | ov | ov.as_json }
    }
  end

  def custom_image_url
    i = custom_image
    if i
      i.attachment.url(:product)
    else
      ''
    end
  end

  def custom_image
    if images.count > 0
      images.first
    else
      product.images.first
    end
  end

  def custom_description
      if images.count > 0
        if images.first.alt.nil? || images.first.alt.length <=0
          product.description
        else
          images.first.alt
        end
      else
        product.description
      end
  end

end