#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class Share < ActiveRecord::Base
  attr_accessible :user, :subject, :subject_url, :service, :recipients, :message
  serialize :recipients  #the recipients field (an array) will be YAML serialized into the db

  belongs_to :user
  belongs_to :subject, :polymorphic => true  #the subject can be user,album or photo

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

  after_create :after_share_user,  :if => :user?
  after_create :after_share_album, :if => :album?
  after_create :after_share_photo, :if => :photo?



  # Finds all of a user's shares for a given album and
  # delivers them. If the shares had already been delivered,
  # they wont be delivered again.
  def self.deliver_shares( user_id, subject_id )
    if subject_id.nil? || user_id.nil?
      raise Exception.new("Subject Id and User Id cannot be nil")
    end

    shares = Share.find_all_by_user_id_and_subject_id(user_id, subject_id)
    shares.each { |share|  ZZ::Async::DeliverShare.enqueue( share.id ) }
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
          ZZ::Async::Email.enqueue( :album_shared_with_you, self.user_id, recipient, self.subject_id, self.message )
        end
      when 'social'
        self.recipients.each do | service |
          ZZ::Async::Social.enqueue( service, self.user_id, self.subject_url, self.message )
        end
    end
    self.sent_at = Time.now
    sa = ShareActivity.create( :user => self.user, :album => self.subject, :share => self )
    self.subject.activities << sa
    self.save
    true #return true
  end


  # after_create callback for users
  def after_share_user
    #TODO: implement after_create callback for users in Share.rb
  end


  # after_create callback for albums.
  # Ensures there ia an UploadBatch open so that when it closes, the share gets delivered
  # adds viewer persmissions to recipients of email share
  def after_share_album
    # get the current batch (make sure a batch is open, since
    # shares will be delivered when the current batch is finished)
    UploadBatch.get_current( self.user_id, self.subject_id )

    # Add VIEWER permsission to the recipients of this email share
    if email?
      recipients.each { |email| subject.add_viewer( email ) } if email?
    end
  end

  # after_create callback for photos
  def after_share_photo
    #TODO: implement after_create callback for photos in Share.rb
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

end
