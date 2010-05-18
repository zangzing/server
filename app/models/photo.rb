# == Schema Information
# Schema version: 20100513233433
#
# Table name: photos
#
#  id                 :integer         not null, primary key
#  album_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#  user_id            :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

# == Schema Information
# Schema version: 20100511235524
#
# Table name: photos
#
#  id         :integer         not null, primary key
#  album_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#
require 'paperclip'


class Photo < ActiveRecord::Base
  attr_accessible :image
  belongs_to :album

  has_attached_file :image,
                    :styles => { :medium =>"300x300>", :thumb   => "100x100#" },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style/:basename.:extension",
                    :bucket => 'sample-app-maxima25-com'


                      #,:url => "/:attachment/:id_:style.:extension",
                      #,:path => ":rails_root/public/:attachment/:id_:style.:extension"

  validates_presence_of :album_id
  validates_attachment_presence :image
  validates_attachment_size     :image, :less_than => 2.megabytes
  validates_attachment_content_type :image,
                                    :content_type => [ 'image/jpeg', 'image/png', 'image/gif' ], :message => "Only JPEG, PNG, or GIF Images allowed"
  
  default_scope :order => 'created_at DESC'



end                       
