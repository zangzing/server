# == Schema Information
# Schema version: 60
#
# Table name: recipients
#
#  id         :integer         not null, primary key
#  share_id   :integer
#  type       :string(255)
#  name       :string(255)
#  address    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Recipient < ActiveRecord::Base
  belongs_to :share

  validate_on_create :service_credentials
  #validates_presence_of :share_id   #TODO: Nested model forms and updates fail with this validation because of a Rails 2.3.5 bug will be fixed for rails 3

  private
  def service_credentials
    case self.service
      when 'facebook', 'twitter'
        #verify that the user has a valid facebook identity
        user = User.find( self.address );
        errors.add(:name,  "User id not set for #{self.service.capitalize} Recipient") unless user
        errors.add_to_base("#{self.service.capitalize} Credentials Not Set (or expired)")  unless user.send("identity_for_#{self.service}").credentials_valid?
      when 'email'
         #:TODO Validate email recipients
    end
  end
end
