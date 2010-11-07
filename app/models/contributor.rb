#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

#
# Contributors are email addresses allowed to contribute content  to an album
# If a contributor is a user then the user_id field will be populated
# If a contributor is not a user and a contribution is received, an absentee user account
# is created. An absentee user account can be made a regular account by trying to create an account with the
# same email address.
class Contributor < ActiveRecord::Base
  attr_accessible :name, :email

  belongs_to :album
  belongs_to :user

  validates_presence_of :album_id
  validates_presence_of :email
  validates_format_of   :email,
                        :with       => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                        :message    => 'must be a valid email address'
  validates_uniqueness_of :email, :scope => :album_id, :message => "is already registered as a contributor for this album."

  before_create :set_user_id
  after_create :deliver_notification

  def self.factory( album, addresses = [] )
    return if album.nil? || addresses.nil?
    # create one or many contributors depending on the number of addresses given
    addresses = [addresses] unless addresses.is_a? Array
    addresses.each do |a|
      c = Contributor.singleton_factory( album, a )
    end
  end

  def is_a_user?
    if self.user.nil?
       user = User.find_by_email( self.email )
       if user.nil?
         return false
       else
         self.user = user
         return self.user.id
       end
    else
      return self.user_id
    end
  end

  def photos
    return [] unless self.is_a_user?
    @photos ||= Photo.find_all_by_user_id_and_album_id(self.user_id, self.album_id )
  end

  def deliver_notification
    ZZ::Async::Email.enqueue( :contributors_added, self.id )
  end

  private
  def set_user_id
     self.is_a_user?
     true #its a before save filter, always return true to avoid stopping the save
  end  

  def self.singleton_factory( album, address )
    c = nil
    matches = address.match(/^"(.*)" <(.*)>$/i)
    if matches
      c = album.contributors.build( :name => matches[1], :email => matches[2])
    else
      c = album.contributors.build( :email => address )
    end
    if !c.valid?
         if msg = c.errors.on(:email)
            c.errors.clear
            c.errors.add(:email,  address+' '+msg  )
         end
         raise ActiveRecord::RecordInvalid.new( c )
    end
  end
end
