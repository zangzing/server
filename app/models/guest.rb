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

  def self.register( email, source )
    guest = Guest.find_or_create_by_email( :email => email)
    user = User.find_by_email( email )
    if user && user.automatic? == false
      guest.user_id = user.id
      unless user.active?
        user.activate!
        user.deliver_welcome!
      end
      guest.status = "Active Account"
    end
    guest.source = source
    guest.save
    guest
  end

  def self.search(search)
    if search
      find(:all, :conditions => ['email LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
end