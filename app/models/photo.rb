# == Schema Information
# Schema version: 20100526143648
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
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", #Config file also contains :bucket
                    :path => ":attachment/:id/:style/:basename.:extension",
                    :whiny => true






  validates_presence_of             :album_id
  validates_attachment_presence     :image,
                                    :message => "file must be specified"
  validates_attachment_size         :image,
                                    :less_than => 5.megabytes,
                                    :message => "must be under 5 Megs"
  validates_attachment_content_type :image,
                                    :content_type => [ 'image/jpeg', 'image/png', 'image/gif' ],
                                    :message => " must be a JPEG, PNG, or GIF"
  
  default_scope :order => 'created_at DESC'

  def thumb_url
    image.url(:thumb)
  end

  def thumb_path
    image.path(:thumb)
  end
end                       
