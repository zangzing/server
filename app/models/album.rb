# == Schema Information
# Schema version: 60
#
# Table name: albums
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  privacy         :integer
#  type            :string(255)
#  style           :integer         default(0)
#  open            :boolean
#  event_date      :datetime
#  location        :string(255)
#  stream_share_id :integer
#  reminders       :boolean
#  name            :string(255)
#  suspended       :boolean
#  created_at      :datetime
#  updated_at      :datetime
#

#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Album < ActiveRecord::Base
  usesguid
  attr_accessible :name, :privacy

  belongs_to :user
  has_many :photos,           :dependent => :destroy
  has_many :shares,           :dependent => :destroy
  has_many :album_activities, :dependent => :destroy
  has_many :upload_batches

  has_attached_file :picon, Paperclip.options[:picon_options]
  before_picon_post_process       :set_picon_metadata

  validates_presence_of  :user_id
  validates_presence_of  :name
  validates_length_of    :name, :maximum => 50

  default_scope :order => 'created_at DESC'

  PRIVACIES = {'Public' =>'public','Hidden' => 'hidden'};

  # All url, path and form helpers treat all subclasses as Album
  def self.model_name
    name = "album"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
      def human;    singularize; end # only for Rails 3
    end
    return name
  end

  def cover
    return nil if self.photos.nil?
    if self.cover_photo_id.nil?
      self.cover_photo_id = self.photos.first.id
      self.save
      return self.photos.first
    else
      return Photo.find( self.cover_photo_id )
    end
  end

  def cover=( photo )
    if self.photos.find( photo )
      self.cover_photo_id = photo.id
      self.save
      self.update_picon_later
    end
  end

  def update_picon
      self.picon = Picon.build( self )
      self.save
  end
  
  def update_picon_later
     Delayed::CpuBoundJob.enqueue Delayed::PerformableMethod.new(self, :update_picon, [] )
  end

  def set_picon_metadata
    self.picon_path   = picon.path.gsub(picon.original_filename,'')
    self.picon_bucket = picon.instance_variable_get("@bucket")
  end
end
