#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
require 'mail'
class Contact < ActiveRecord::Base
  belongs_to :identity
  validates_presence_of :identity

  #this method is used by to_json. Whatever this method outputs will be converted to_json
  def as_json(options={})
     [ self.name, self.address ]
  end

  def formatted_email
    "#{self.name} <#{self.address}>"
  end
end
