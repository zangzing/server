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
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Identity < ActiveRecord::Base

  belongs_to :user
  has_many :contacts, :dependent => :destroy

  validates_presence_of :user

  UI_INFO = {
    :google => {:name => 'Google', :icon => ''},
    :flickr => {:name => 'Flickr', :icon => ''},
    :yahoo => {:name => 'Yahoo!', :icon => ''},
    :facebook => {:name => 'Facebook', :icon => ''},
    :twitter => {:name => 'Twitter', :icon => ''},
    :smugmug => {:name => 'SmugMug', :icon => ''},
    :shutterfly => {:name => 'Shutterfly', :icon => ''},
    :kodak => {:name => 'Kodak Gallery', :icon => ''},
    :local => {:name => 'ZangZing Agent', :icon => ''}
  }

  def name
    UI_INFO[self.identity_source.to_sym][:name]
  end
  
end
