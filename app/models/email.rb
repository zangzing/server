class Email < ActiveRecord::Base
  attr_accessible :production_template_id, :name

  belongs_to  :production_template, :class_name => "EmailTemplate"
  has_many    :email_templates

  validates :name, :uniqueness => true

  scope :outer_template, where(:name => 'outer_template')

  INVITES       ='invites'
  SOCIAL        ='social'
  STATUS        ='status'
  NEWS          ='news'
  MARKETING     ='marketing'
  TRANSACTIONAL ='transactional'
  ONCE          ='once'

end