# == Schema Information
# Schema version: 60
#
# Table name: identities
#
#  id                   :integer         not null, primary key
#  user_id              :integer
#  type                 :string(255)
#  name                 :string(255)
#  credentials          :string(255)
#  last_contact_refresh :datetime
#  identity_source      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Identity < ActiveRecord::Base
  extend ZZActiveRecordUtils

  belongs_to :user
  has_many :contacts, :dependent => :destroy

  validates_presence_of :user

  def self.factory( user, identity_source )
    class_name = identity_source.capitalize+'Identity'
    begin
       @new_id = class_name.constantize.new(:identity_source => identity_source )
    rescue NameError
       @new_id = Identity.new(:identity_source => identity_source)
    end
    user.identities << @new_id
    @new_id.save!
    return @new_id
  end

  # return as a boolean
  def has_credentials?
    # verify_credentials is used when you want to see if they are actually verified
    (self.identity_source.to_sym == :local) || !!self.credentials   # the !! turns nil into false
  end

  # If specific service supports it, do an active verification
  # now, otherwise just tells us that credentials have been set.
  # returns true if verified, false otherwise
  #
  # Note, this call is potentially high overhead so only issue
  # when you truly need to verify with the service that the credentials
  # are indeed valid.
  def verify_credentials
    has_credentials?  # by default if not overridden just checks to see if set
  end

  UI_INFO = {
    :google => {:name => 'Gmail and Picasa Web', :icon => ''},
    #:picasa => {:name => 'Picasa Web Albums', :icon => ''},
    :flickr => {:name => 'Flickr', :icon => ''},
    :yahoo => {:name => 'Yahoo!', :icon => ''},
    :facebook => {:name => 'Facebook', :icon => ''},
    :twitter => {:name => 'Twitter', :icon => ''},
    :smugmug => {:name => 'SmugMug', :icon => ''},
    :photobucket => {:name => 'Photobucket', :icon => ''},
    :instagram => {:name => 'Instagram', :icon => ''},
    :dropbox => {:name => 'Dropbox', :icon => ''},
    :mobileme => {:name => 'MobileMe', :icon => ''},
    :shutterfly => {:name => 'Shutterfly', :icon => ''},
    :kodak => {:name => 'Kodak Gallery', :icon => ''},
    :local => {:name => 'ZangZing Local Contacts', :icon => ''},
    :mslive => {:name => 'Hotmail', :icon => ''}
  }

  # check to see if the service name passed is
  # valid
  def self.is_valid_service_name?(name)
    info = UI_INFO[name.to_sym]
    !!info
  end

  def name
    UI_INFO[self.identity_source.to_sym][:name]
  end

  def destroy_contacts
    Contact.connection.execute "DELETE FROM #{Contact.quoted_table_name} WHERE `identity_id` = #{self.id}"
  end

  def import_contacts(contacts_array)
    db = Contact.connection

    cmd = "INSERT INTO #{Contact.quoted_table_name} (identity_id, name, address, created_at, updated_at) VALUES "

    # build an array of arrays that contain the data to insert
    identity_id = self.id
    now = DateTime.now
    rows = []
    contacts_array.each do |contact|
      row = [ identity_id, contact.name, contact.address, now, now ]
      rows << row
    end

    RawDB.fast_insert(db, rows, cmd)

    return contacts_array.count
  end

  
end
