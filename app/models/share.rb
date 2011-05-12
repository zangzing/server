#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class Share < ActiveRecord::Base
  attr_accessible :user, :subject, :subject_url, :service, :recipients, :message
  serialize :recipients  #the recipients field (an array) will be YAML serialized into the db

  belongs_to :user
  belongs_to :subject, :polymorphic => true  #the subject can be user,album or photo
  belongs_to :upload_batch

  validates_presence_of :user_id, :subject_id, :subject_type, :recipients

  validates  :service, :presence => true, :inclusion => { :in => %w{email social} }

  #if the service is email the recipients array can only contain valid email addresses
  validates_each  :recipients, :if => :email? do |record, attr, value|
    value.each do |email|
      record.errors.add attr, "Email address not valid: "+email unless ZZ::EmailValidator.validate( email )
    end
  end

  #if the service is social the recipients array can only contain facebook and/or twitter
  validates_each  :recipients, :if => :social? do |record, attr, value|
    value.each do |recipient|
      record.errors.add attr, recipient+" Social service not supported" unless  %w{ twitter facebook}.include?( recipient )
    end
  end




  before_create  :attach_to_open_batch, :if => :album?
  after_commit :after_share_user,  :if => :user?,  :on => :create
  after_commit :after_share_album, :if => :album?, :on => :create
  after_commit :after_share_photo, :if => :photo?, :on => :create



  # Finds all of a user's shares for a given album and
  # delivers them. If the shares had already been delivered,
  # they wont be delivered again.
  def self.deliver_shares( user_id, subject_id )
    if subject_id.nil? || user_id.nil?
      raise Exception.new("Subject Id and User Id cannot be nil")
    end

    shares = Share.find_all_by_user_id_and_subject_id(user_id, subject_id)
    shares.each { |share|  ZZ::Async::DeliverShare.enqueue( share.id ) if share.sent_at.nil? }
  end


  # Queues the share for delivery
  # It will queue a job in the mail queue for each email for email shares
  # It will queue a job in the facebook and/or twitter queues for social shares
  def deliver
    #prevent shares from being delivered twice
    return false unless self.sent_at.nil?

    case service
      when 'email'
        self.recipients.each do |recipient |
          #TODO: Add Album.Photo.User handling See bug #1124
          Guest.register( recipient, 'share' ) #add recipient to guest list for beta period
          ZZ::Async::Email.enqueue( :album_shared, self.user_id, recipient, self.subject_id, self.message ) if album?
          ZZ::Async::Email.enqueue( :photo_shared, self.user_id, recipient, self.subject_id, self.message ) if photo?
        end
      when 'social'
        self.recipients.each do | service |
          user.send("identity_for_#{service}").post_share( self )
        end
    end
    self.sent_at = Time.now

    if album?
      sa = ShareActivity.create( :user => self.user, :album => self.subject, :share => self )
      self.subject.activities << sa
    elsif photo?
      sa = ShareActivity.create( :user => self.user, :album => self.subject.album, :share => self )
      self.subject.album.activities << sa
    elsif user?
#      sa = ShareActivity.create( :user => self.user, :user => self.subject, :share => self )
    end


    self.save
    true #return true
  end


  # after_create callback for users
  def after_share_user
    ZZ::Async::DeliverShare.enqueue( self.id )
  end


  # before_create callback for albums.
  def attach_to_open_batch
    # Look for an open current batch if there is one, attach to it
    open_batch = UploadBatch.find_by_user_id_and_album_id_and_state(user_id, subject_id, 'open')
    self.upload_batch_id = open_batch.id if open_batch
  end

  # after_create callback for albums.
  def after_share_album
    #if the share is attached to a batch, it will be delivered by the batch, otherwise deliver now
    ZZ::Async::DeliverShare.enqueue( self.id ) unless self.upload_batch_id

    # if the owner is sharing the album, add VIEWER permsission
    # to the recipients of this email share (if this is an email share)
    if email? && subject.user.id == user_id
      recipients.each { |email| subject.add_viewer( email ) } 
    end
  end

  # after_create callback for photos
  def after_share_photo
    ZZ::Async::DeliverShare.enqueue( self.id )
  end

  def email?
    self.service == 'email'
  end

  def social?
    self.service == 'social'
  end

  def album?
    self.subject_type == 'Album'
  end

  def user?
    self.subject_type == 'User'
  end

  def photo?
    self.subject_type == 'Photo'
  end

  def instant?
    self.upload_batch_id.nil?
  end

end
