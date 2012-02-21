require 'digest/sha1'

# Subscriptions
#
# Subscriptions records are kept for all email addresses to which we have sent email.
# Subscription records allow users and non-user to unsubscribe from our service.
#
# Testing for user.nil? is the preferred method to find out  which subscriptions are assoicated to a user
# and which are only tracking known emails.
#
# When a user is created we review existing subscriptions and if a record exists for
# their email, the subscription record is associated to them otherwise a new one is created.
#
# Methods in this class must work for user and non-user subscription records.
#


class Subscriptions< ActiveRecord::Base
  attr_accessible :email, :user_id,
                  :want_marketing_email, :want_news_email, :want_social_email, :want_status_email, :want_invites_email


  belongs_to  :user

  validates_presence_of :email


  before_save( :if => :email_changed? ) do
    @update_mailing_list_user = email_was
    self.unsubscribe_token = Digest::SHA1.hexdigest( UNSUBSCRIBE_TOKEN_SECRET+ self.email )
  end

  after_commit( :if => :update_mailing_list_user? ) do
      if user
        ZZ::Async::MailingListSync.enqueue( 'update_user', @update_mailing_list_user , user.id )
      end
      @update_mailing_list_user = nil
  end

  NEVER       = 0
  IMMEDIATELY = 1
  DAILY       = 2
  WEEKLY      = 3

  UNSUBSCRIBE_TOKEN_SECRET = "This-is-a-secret-number-6872296"


  def update_mailing_list_user?
    @update_mailing_list_user
  end

  def user_id=( id )
    self.user = User.find(id)
  end

  def user=( user )
    write_attribute( :user_id, user.id )
    write_attribute( :email, user.email )
  end

  def unsubscribe( kind = nil, period = nil )
    period = NEVER if period.nil?
    if  kind
      case kind
        when Email::INVITES   then  self.want_invites_email   = period
        when Email::SOCIAL    then  self.want_social_email    = period
        when Email::STATUS    then  self.want_status_email    = period
        when Email::NEWS      then  self.want_news_email      = period
        when Email::MARKETING then  self.want_marketing_email = period
        #There is no unsubscribe for Email::ONCE
      end        
    else
      self.want_invites_email   = period
      self.want_social_email    = period
      self.want_status_email    = period
      self.want_news_email      = period
      self.want_marketing_email = period
    end
    self.save
  end
  alias update_subscription :unsubscribe

  def wants_email?( zzemail )
    false if zzemail.nil?
    allow = case zzemail.kind
              when Email::TRANSACTIONAL: true
              when Email::INVITES   then  want_invites_email   > NEVER
              when Email::SOCIAL    then  want_social_email    > NEVER
              when Email::STATUS    then  want_status_email    > NEVER
              when Email::NEWS      then  want_news_email      > NEVER
              when Email::MARKETING then  want_marketing_email > NEVER
              else false
            end
    update_email_track( zzemail ) if allow
    allow
  end

  def wants_email!( zzemail )
    unless wants_email?( zzemail )
      if user
        raise SubscriptionsException.new( "SUBSCRIPTIONS: #{user.id} #{user.name} does not want to receive message: #{zzemail.name} kind: #{zzemail.kind}" )
      else
        raise SubscriptionsException.new( "SUBSCRIPTIONS: #{email} does not want to receive message: #{zzemail.name} kind: #{zzemail.kind}" )
      end  
    end
  end

  def self.unsubscribe_token( recipient )
    if recipient.is_a?User
      recipient.subscriptions.unsubscribe_token
    else
      Subscriptions.find_or_create_by_email( recipient ).unsubscribe_token
    end
  end


  def self.wants_email!( recipient,  zzemail )
     if recipient.is_a?User
       recipient.subscriptions.wants_email!( zzemail  )
     else
       Subscriptions.find_or_create_by_email( recipient ).wants_email!( zzemail )
     end
  end

  # When the marketing preferences change, update subscriptions to marketing mailing lists
  def want_marketing_email=( period )
    write_attribute( :want_marketing_email, period )

    # Subscriptions records are kept for emails (with no associated users) and
    # for emails with associated users, if it is a user then update mailing lists
    if user
      if self.want_marketing_email_changed?
        if period.to_i == NEVER
          #unsubscribe from mailing lists
          ZZ::Async::MailingListSync.enqueue('unsubscribe_user', Email::MARKETING, user.id )
        else
          #subscribe to marketing mailing lists
          ZZ::Async::MailingListSync.enqueue('subscribe_user', Email::MARKETING, user.id )
        end
      end
    end
  end

  # When the news preferences change, update subscriptions to news mailing lists
  def want_news_email=( period )
    write_attribute( :want_news_email, period )
    # Subscriptions records are kept for emails (with no associated users) and
    # for emails with associated users, if it is a user then update mailing lists
    if user
      if self.want_news_email_changed?
        if period.to_i == NEVER
          #unsubscribe from mailing lists
          ZZ::Async::MailingListSync.enqueue('unsubscribe_user', Email::NEWS, user.id )
        else
          #subscribe to marketing mailing lists
          ZZ::Async::MailingListSync.enqueue('subscribe_user', Email::NEWS, user.id )
        end
      end
    end
  end


  private
  def update_email_track( zzemail )
    self.last_email_kind = zzemail.kind
    self.last_email_name = zzemail.name
    self.last_email_at   = Time.now
    self.save
  end

end
