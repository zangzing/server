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
    self.identity_source.to_sym == :local || self.credentials
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
    :shutterfly => {:name => 'Shutterfly', :icon => ''},
    :kodak => {:name => 'Kodak Gallery', :icon => ''},
    :local => {:name => 'ZangZing Local Contacts', :icon => ''},
    :mslive => {:name => 'Windows Live ID', :icon => ''}
  }

  def name
    UI_INFO[self.identity_source.to_sym][:name]
  end

  def destroy_contacts
    Contact.connection.execute "DELETE FROM #{Contact.quoted_table_name} WHERE `identity_id` = #{self.id}"
  end
  
  def import_contacts(contacts_array)
    page_size = 100 #Decrease this if u're getting errors like 'SQL Statement too big'
    columns_to_update = ['name', 'address', 'identity_id']
    
    page_start = 0
    imported_count = 0
    columns = columns_to_update.map { |name| Contact.columns_hash[name] }
    while page_start <= contacts_array.size
      page = contacts_array[page_start, page_size]
      page.each{|c| c.identity_id = self.id} #To fit validation
      value_blocks = page.select(&:valid?).map do |contact|
        columns.map do |col|
          Contact.connection.quote(col.type_cast(contact.attributes[col.name]), col)
        end
      end
      next if value_blocks.empty?
      sql = "INSERT INTO #{Contact.quoted_table_name}(#{columns_to_update.join(',')},created_at,updated_at) VALUES"
      sql += value_blocks.map {|v| "(#{v.join(',')},NOW(),NOW())" }.join(',')
      begin
        Contact.connection.execute sql
      ensure
        imported_count += value_blocks.size
      end
      page_start += page_size
    end
    imported_count
  end

  
end
