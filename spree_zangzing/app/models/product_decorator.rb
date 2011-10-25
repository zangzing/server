Product.class_eval do

  def short_description
    return description
  end

  def long_description
    return description
  end

  def as_json( options={} )

    {
          :id => id,
          :name => name,
          :description => short_description,
          :options =>  option_types.collect{ | ot | ot.as_json },
          :variants => variants.active.collect{ |v |  v.as_json },
          :image_url => images.first ? images.first.attachment.url(:product) : nil
    }
  end
  
end

