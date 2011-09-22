Product.class_eval do

  def as_json( options={} )
    {
          :id => id,
          :name => name,
          :description => description,
          :options =>  option_types.collect{ | ot | ot.as_json },
          :variants => variants.active.collect{ |v |  v.as_json }
    }
  end
  
end

