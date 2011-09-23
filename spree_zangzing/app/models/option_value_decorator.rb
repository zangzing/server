OptionValue.class_eval do
  def as_json
    {
      :id => id,
      :type_id => option_type.id,
      :name => presentation
    }
  end

end