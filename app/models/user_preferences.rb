class UserPreferences < ActiveRecord::Base
  attr_accessible

  belongs_to  :user

  
end