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
  has_many :activities,       :dependent => :destroy
  has_many :upload_batches
  has_many :contributors

  has_attached_file :picon, Paperclip.options[:picon_options]
  before_picon_post_process    :set_picon_metadata

  validates_presence_of  :user_id
  validates_presence_of  :name
  validates_length_of    :name, :maximum => 50

  before_create :set_email
  before_save   :set_email, :if => :name_changed?

  default_scope :order => 'created_at DESC'

  PRIVACIES = {'Public' =>'public','Hidden' => 'hidden','Password' => 'password'};

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
    return nil if self.photos.empty?
    if self.cover_photo_id.nil?
      return self.photos.first
    else
      return Photo.find( self.cover_photo_id )
    end                        
  end

  def cover=( photo )
    if photo.nil?
       return if self.cover_photo_id.nil? # cover has not changed do not do anything
       self.cover_photo_id = nil;
    else
      return if self.cover_photo_id == photo.id # cover has not changed do not do anything
      self.cover_photo_id = photo.id if self.photos.find( photo )
    end
    self.save
    self.update_picon_later
  end

  def update_picon
      self.picon.clear unless self.picon.nil?
      self.picon = Picon.build( self )
      self.save
  end
  
  def update_picon_later
     Delayed::CpuBoundJob.enqueue Delayed::PerformableMethod.new(self, :update_picon, [] )
  end

  def picon_url
    picon.instance_variable_set '@bucket', self.picon_bucket unless self.picon_bucket.nil?
    picon.url
  end

  def set_picon_metadata
    logger.debug("In picon before post")
    self.picon_path   = picon.path.gsub(picon.original_filename,'')
    self.picon_bucket = picon.instance_variable_get("@bucket")
  end

  def is_contributor?( email )
    c = self.contributors.find_by_email( email );
    if c
      return User.find_by_email_or_create_automatic( c.email, c.name )
    end
  end

  def is_user_contributor?( user )
    return is_contributor? user.email
  end

  def long_email
      " \"#{self.name}\" <#{self.id}@#{ALBUM_EMAIL_HOST}>"
  end

  def short_email
      "#{self.id}@#{ALBUM_EMAIL_HOST}"
  end

  private
  def set_email
      # Remove spaces and @
      self.email = dashify(name)
  end

  def dashify( s )
      # change everything to lowercase
      # trim leading and trailing spaces
      # change all spaces and underscores to a hyphen
      # remove all non-alphanumeric characters except the hyphen
      # replace multiple instances of the hyphen with a single instance
      # trim leading and trailing hyphens
      s.downcase.gsub(/^\s+|\s+$/, "").gsub(/[_|\s]+/, "-").gsub(/[^a-z0-9-]+/, "").gsub(/[-]+/, "-").gsub(/^-+|-+$/, "")
  end
end
