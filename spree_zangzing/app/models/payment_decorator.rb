Payment.class_eval do

  attr_accessor :creditcard_id
  before_save   :create_source_from_ccid, :if => "@creditcard_id"


  # If the attr accessor creditcard_id has been set,
  #  create a creditcard using the given id.
  def create_source_from_ccid
      creditcard = Creditcard.find_by_id( @creditcard_id  )
      if creditcard
        self.source = creditcard
      end
  end

end