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

  def credentials_valid?
    # we may want to validate with a call to the specific service
    self.credentials
  end

  UI_INFO = {
    :google => {:name => 'Google', :icon => ''},
    #:picasa => {:name => 'Picasa Web Albums', :icon => ''},
    :flickr => {:name => 'Flickr', :icon => ''},
    :yahoo => {:name => 'Yahoo!', :icon => ''},
    :facebook => {:name => 'Facebook', :icon => ''},
    :twitter => {:name => 'Twitter', :icon => ''},
    :smugmug => {:name => 'SmugMug', :icon => ''},
    :photobucket => {:name => 'Photobucket', :icon => ''},
    :instagram => {:name => 'Instagram', :icon => ''},
    :shutterfly => {:name => 'Shutterfly', :icon => ''},
    :kodak => {:name => 'Kodak Gallery', :icon => ''},
    :local => {:name => 'ZangZing Local Contacts', :icon => ''},
    :mslive => {:name => 'Windows Live ID', :icon => ''}
  }

  def name
    UI_INFO[self.identity_source.to_sym][:name]
  end
  
end
