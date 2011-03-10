#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class Share < ActiveRecord::Base
  attr_accessible :user, :subject, :subject_url, :service, :recipients, :message
  serialize :recipients

  belongs_to :user
  belongs_to :subject, :polymorphic => true

  validates_presence_of :user_id, :subject_id, :subject_type, :recipients

  validates  :service, :presence => true, :inclusion => { :in => %w{email social} }
  
  validates_each  :recipients, :if => 'service == "email"' do |record, attr, value|
      value.each do |email|
          record.errors.add attr, "Email address not valid: "+email unless ZZ::EmailValidator.validate( email )
      end
   end

  validates_each  :recipients, :if => 'service == "social"' do |record, attr, value|
     value.each do |recipient|
        record.errors.add attr, recipient+" Social service not supported" unless  %w{ twitter facebook}.include?( recipient )
      end
   end
 
  
  def self.deliver_shares( user_id, subject_id )
    if subject_id.nil? || user_id.nil?
      raise Exception.new("Subject Id and User Id cannot be nil")
    end

    shares = Share.find_all_by_user_id_and_subject_id(user_id, subject_id)
    shares.each { |share|  ZZ::Async::DeliverShare.enqueue( share.id ) }
  end

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
     return true
  end

end
