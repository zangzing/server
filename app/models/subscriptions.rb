require 'digest/sha1'

class Subscriptions< ActiveRecord::Base
  attr_accessible :email, :user_id,
                  :want_marketing_email, :want_news_email, :want_social_email, :want_status_email, :want_invites_email


  belongs_to  :user

  validates_presence_of :email

  before_save( :if => :email_changed? ) do
    self.unsubscribe_token = Digest::SHA1.hexdigest( UNSUBSCRIBE_TOKEN_SECRET+ self.email )
  end

  NEVER       = 0
  IMMEDIATELY = 1
  DAILY       = 2
  WEEKLY      = 3

  UNSUBSCRIBE_TOKEN_SECRET = "This-is-a-secret-number-6872296"

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


  def wants_email?( kind, name )
    false if kind.nil?
    allow = case kind
              when Email::TRANSACTIONAL: true
              when Email::INVITES   then  want_invites_email   > NEVER
              when Email::SOCIAL    then  want_social_email    > NEVER
              when Email::STATUS    then  want_status_email    > NEVER
              when Email::NEWS      then  want_news_email      > NEVER
              when Email::MARKETING then  want_marketing_email > NEVER
              else false
            end
    update_email_track( kind, name ) if allow
    allow
  end

  def wants_email!( kind, name )
    unless wants_email?( kind, name)
      raise SubscriptionsException.new( "SUBSCRIPTIONS: #{user.id} #{user.name} does not want to receive message: #{name} kind: #{kind}" )
    end
  end



  def self.unsubscribe_token( recipient )
    if recipient.is_a?User
      recipient.subscriptions.unsubscribe_token
    else
      Subscriptions.find_or_create_by_email( recipient ).unsubscribe_token
    end
  end


  def self.wants_email?( recipient,  kind, name )
    if recipient.is_a?User
      recipient.preferences.wants_email?( kind, name  )
    else
      Subscriptions.find_or_create_by_email( recipient ).wants_email?( kind, name )
    end
  end

  def self.wants_email!( recipient,  kind, name )
     if recipient.is_a?User
       recipient.preferences.wants_email!( kind, name  )
     else
       Subscriptions.find_or_create_by_email( recipient ).wants_email!( kind, name )
     end
  end

  # When the marketing preferences change, update subscriptions to marketing mailing lists
  def want_marketing_email=( period )
    write_attribute( :want_marketing_email, period )
    if self.want_marketing_email_changed?
      lists = MailingList.find_all_by_category( Email::MARKETING )
      if period.to_i == NEVER
        #unsubscribe from marketing mailing lists
        lists.each{ |list| list.unsubscribe_user( self.user )}
      else
        #subscribe to marketing mailing lists
        lists.each{ |list| list.subscribe_user( self.user )}
      end
    end
  end

  # When the news preferences change, update subscriptions to news mailing lists
  def want_news_email=( period )
      write_attribute( :want_news_email, period )
      if self.want_news_email_changed?
        lists = MailingList.find_all_by_category( Email::NEWS )
        if period.to_i == NEVER
          #unsubscribe from mailing lists
          lists.each{ |list| list.unsubscribe_user( self.user )}
        else
          #subscribe to marketing mailing lists
          lists.each{ |list| list.subscribe_user( self.user )}
        end
      end
  end

  # When the email is updated, update mailing list addresses
  def email=(email)
    write_attribute( :email, email)
    if email_changed?

    end
  end


  private
  def update_email_track( kind, name )
    self.last_email_kind = kind
    self.last_email_name = name
    self.last_email_at   = Time.now
    self.save
  end

end
