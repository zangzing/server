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
  attr_accessible :name, :privacy, :cover_photo_id

  belongs_to :user
  has_many :photos,           :dependent => :destroy
  has_many :shares,           :dependent => :destroy
  has_many :activities,       :dependent => :destroy
  has_many :upload_batches
  has_many :contributors
  
  has_friendly_id :name, :use_slug => true, :scope => :user, :reserved_words => ["photos", "shares", 'activities', 'slides_source', 'people'], :approximate_ascii => true


  has_attached_file :picon, Paperclip.options[:picon_options]
  before_picon_post_process    :set_picon_metadata

  validates_presence_of  :user_id
  validates_presence_of  :name
  validates_length_of    :name, :maximum => 50
  validates_length_of    :cover_photo_id, :is => 22, :message => "Invalid ID for cover photo must be GUID(22)", :if => :cover_photo_id_changed?


  #before_create :set_email
  attr_accessor :name_had_changed
  before_save  Proc.new { |model| model.name_had_changed = true }, :if => :name_changed?
  before_save  :cover_photo_id_valid?, :if => :cover_photo_id_changed?
  after_save   :set_email, :if => :name_had_changed
  #before_save   :set_email, :if => :new_slug_needed? #:name_changed?

  default_scope :order => "`albums`.updated_at DESC"

  PRIVACIES = {'Public' =>'public','Hidden' => 'hidden','Password' => 'password'};

  # build our base model name for this class and
  # hold onto it as a class variable since we only
  # need to generate it once.  The name built up
  # has all the support needed by ActiveModel to properly
  # fetch the singular and pluralized versions of the name
  # we do this rather than the default since we want
  # our child classes to use this classes table name
  # in other words we don't want PersonalAlbum to use the
  # personal_albums table we want it to use the 
  # albums table
  def self.model_name
    @@_model_name ||= ActiveModel::Name.new(Album)
  end


  def cover
    return nil if self.photos.empty?
    if self.cover_photo_id.nil?
      self.photos.first
    else
      @cover ||= self.photos.find( self.cover_photo_id )
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
  end

  def update_picon
      self.picon.clear unless self.picon.nil?
      self.picon = ZZ::Picon.make( self )
      self.save
  end
  
  def queue_update_picon
     ZZ::Async::UpdatePicon.enqueue( self.id )
  end

  def picon_url
    picon.instance_variable_set '@bucket', self.picon_bucket unless self.picon_bucket.nil?
    picon.url
  end

  def set_picon_metadata
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
      " \"#{self.name}\" <#{short_email}>"
  end

  def short_email
      "#{self.id}@#{Server::Application.config.album_email_host}"
  end

  def to_param #overide friendly_id's
    (id = self.id) ? id.to_s : nil
  end

private
  def cover_photo_id_valid?
    begin
      if cover_photo_id.length == 22 && photos.find(cover_photo_id)
        queue_update_picon
        return true
      end
    rescue ActiveRecord::RecordNotFound => e
       errors.add(:cover_photo_id,"Could not find photo with ID:"+cover_photo_id+" in this album")
    end
    return false
  end

  def set_email
    # Remove spaces and @
    mail_address = "#{self.friendly_id}.#{self.user.friendly_id}"
    self.connection.execute "UPDATE `albums` SET `email`='#{mail_address}' WHERE `id`='#{self.id}'" if self.id
    self.name_had_changed = false
    #self.email = dashify(name)
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
