OptionType.class_eval do
  def as_json
    {
      :id => id,
      :name => presentation,
      :values => option_values.collect { | ov | ov.as_json }
    }
  end
end