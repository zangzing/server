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
  validates_format_of   :email,
                        :with       => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                        :message    => 'must be a valid email address'
  validates_uniqueness_of :email, :scope => :album_id, :message => "is already registered as a contributor for this album."
  before_create :set_user_id

  def self.factory( album, addresses = [] )
    return if album.nil? || addresses.nil?
    # create one or many contributors depending on the number of addresses given
    addresses = [addresses] unless addresses.is_a? Array
    addresses.each do |a|
      c = Contributor.singleton_factory( album, a )
    end
  end

  def is_a_user?
    self.user_id ||= ( @user = User.find_by_email( self.email ) ? @user.id : false )
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
       album.contributors.create( :name => matches[1], :email => matches[2] )
   else
      album.contributors.create( :email => address )
    end
  end
end
