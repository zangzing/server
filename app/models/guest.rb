class Guest < ActiveRecord::Base

  validates_uniqueness_of :email, :message => "Already on Guest List"

  validates_each  :email do |record, attr, value|
      record.errors.add attr, value+" is not a valid address " unless ZZ::EmailValidator.validate( value )
  end

  belongs_to :user

  def beta_lister?
    self.source == 'beta' || self.source == 'admin'
  end

  def share?
    self.source == 'share' || self.source == 'contributor'
  end

end