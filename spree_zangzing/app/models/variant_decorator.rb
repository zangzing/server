Variant.class_eval do
  include ActionView::Helpers::NumberHelper

  unless defined? MIN_DPI
    MIN_DPI = 100
    DEFAULT_MIN_PHOTO_WIDTH = 3000
    DEFAULT_MIN_PHOTO_HEIGHT = 2000
  end


  def as_json
    {
      :id => id,
      :sku => sku,
      :price => number_to_currency( price ),
      :description => custom_description,
      :image_url => custom_image_url,
      :values => option_values.select{ |ov| ov.presentation.downcase != 'framed' }.collect { | ov | ov.as_json },
      :min_photo_width => self.width ? self.width * MIN_DPI : DEFAULT_MIN_PHOTO_WIDTH,
      :min_photo_height => self.height ? self.height * MIN_DPI : DEFAULT_MIN_PHOTO_HEIGHT
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

  def print?
    product.name == "Prints" && price < Spree::Config[:printset_threshold]
  end

end