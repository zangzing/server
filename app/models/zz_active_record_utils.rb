# handy utils to include in your active record models
module ZZActiveRecordUtils

  # quote a value for using in hand built database query
  def q(value)
    value.nil? ? 'NULL' : connection.quote(value.to_s)
  end
end