#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class Share < ActiveRecord::Base
  attr_accessible :user, :subject, :subject_url, :service, :recipients, :message, :share_type
  serialize :recipients  #the recipients field (an array) will be YAML serialized into the db

  belongs_to :user
  belongs_to :subject, :polymorphic => true  #the subject can be user,album or photo
  belongs_to :upload_batch

  validates_presence_of :user_id, :subject_id, :subject_type, :recipients, :share_type

  validates  :service, :presence => true, :inclusion => { :in => %w{email social} }

  #if the service is email the recipients array can only contain valid email addresses, or group ids
  validates_each  :recipients, :if => :email? do |record, attr, value|
    value.each do |email|
      # see if a number or a valid email, numbers mean group_ids
      record.errors.add attr, "Email address not valid: "+email unless (Integer(email) rescue false) != false || ZZ::EmailValidator.validate( email )
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


  # constants for Share.share_type
  TYPE_VIEWER_INVITE = 'viewer'
  TYPE_CONTRIBUTOR_INVITE = 'contributor'

  # constants for Share.service
  SERVICE_EMAIL = 'email'
  SERVICE_SOCIAL = 'social'


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

    # Create Email or post
    case service
      when 'email'
        emails = Group.flatten_emails(recipients) # flatten groups and emails into just emails
        emails.each do |recipient|
          Guest.register( recipient, 'share' ) #add recipient to guest list for beta period


          if album? && viewer_invite?
            ZZ::Async::Email.enqueue( :album_shared, self.user_id, recipient, self.subject_id, self.message )
          end

          if album? && contributor_invite?
            ZZ::Async::Email.enqueue( :contributor_added, self.subject_id, recipient, self.message )
          end


          if photo?
            ZZ::Async::Email.enqueue( :photo_shared, self.user_id, recipient, self.subject_id, self.message )
          end

        end
      when 'social'
        self.recipients.each do | service |
          user.send("identity_for_#{service}").post_share( self )
        end
    end
    self.sent_at = Time.now

    # Create Share Activity
    if album?
      sa = ShareActivity.create( :user => self.user, :subject => self.subject, :share => self )
      self.subject.activities << sa
    elsif photo?
      sa = ShareActivity.create( :user => self.user, :subject => self.subject.album, :share => self )
      self.subject.album.activities << sa  # Boil activities to the photo album
    elsif user?
      sa = ShareActivity.create( :user => self.user, :subject => self.subject, :share => self )
      self.subject.activities << sa
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
  end

  # after_create callback for photos
  def after_share_photo
    ZZ::Async::DeliverShare.enqueue( self.id )
  end

  def email?
    self.service == SERVICE_EMAIL
  end

  def social?
    self.service == SERVICE_SOCIAL
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

  def viewer_invite?
    self.share_type == TYPE_VIEWER_INVITE
  end

  def contributor_invite?
    self.share_type == TYPE_CONTRIBUTOR_INVITE
  end



end
