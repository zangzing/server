Address.class_eval do
  belongs_to :user
  before_validation :clean_phone, :if => :phone_changed?

   # can modify an address if it's not been used in an order
  def editable?
    new_record? || !user_id.nil?
  end

  def one_line
    "#{firstname} #{lastname} #{address1} #{city} #{state_text}"
  end

  def clean_phone
    self.phone = phone.to_s.gsub(/\D/, '')
  end
end