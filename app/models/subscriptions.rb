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

  def self.wants_email?( recipient,  kind, name )
    if recipient.is_a?User
      recipient.preferences.wants_email?( kind, name  )
    else
      Subscriptions.find_or_create_by_email( recipient ).wants_email?( kind, name )
    end
  end

  private
  def update_email_track( kind, name )
    self.last_email_at   = Time.now
    self.last_email_kind = kind
    self.last_email_name = name
    self.save
  end

end
