Address.class_eval do
  belongs_to :user

   # can modify an address if it's not been used in an order
  def editable?
    new_record? || !user_id.nil?
  end

end