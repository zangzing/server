OptionValue.class_eval do
  def as_json
    {
      :id => id,
      :type_id => option_type.id,
      :name => presentation
    }
  end


  scope :in_line_item, lambda{ |line_item|
    {
        :joins      => :variants,
        :conditions => {:variants => {:id => line_item.variant_id}},
        :select     => "DISTINCT `option_values`.*" # kill duplicates
    }
  }

  scope :framed, where("name = 'FRAME'")

end