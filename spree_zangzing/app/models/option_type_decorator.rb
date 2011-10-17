OptionType.class_eval do
  def as_json
    {
      :id => id,
      :name => presentation,
      :values => option_values.select{ |ov| ov.presentation.downcase != 'framed' }.collect { | ov | ov.as_json }
    }
  end
end