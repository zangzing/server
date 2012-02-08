class TrackedLink < ActiveRecord::Base

  include Rails.application.routes.url_helpers
  default_url_options[:host] = Server::Application.config.application_host


  belongs_to :user

  TYPE_INVITATION = 'invitation'
  TYPE_PHOTO_SHARE = 'photo-share'
  TYPE_ALBUM_SHARE = 'album-share'


  SHARED_TO_EMAIL = 'email'
  SHARED_TO_FACEBOOK = 'facebook'
  SHARED_TO_TWITTER = 'twitter'
  SHARED_TO_COPY_PASTE = 'copy_paste'


  @@test_token = nil

  def self.create_tracked_link(user, url, type, shared_to, shared_to_address=nil)
    tracked_link = TrackedLink.new
    tracked_link.user = user
    tracked_link.link_type = type
    tracked_link.shared_to = shared_to
    tracked_link.shared_to_address = shared_to_address || shared_to
    tracked_link.url = url
    for i in (1..10)
      begin
        tracked_link.tracking_token = generate_token
        tracked_link.save!
        return tracked_link
      rescue ActiveRecord::RecordNotUnique => ex
        last_exception = ex
        next
      end
    end

    raise last_exception
  end

  def self.handle_visit(tracking_token, last_referrer)
    tracked_link = TrackedLink.find_by_tracking_token(tracking_token)
    tracked_link.last_referrer = last_referrer
    tracked_link.save

    TrackedLink.increment_counter(:visit_count, tracked_link.id)
  end

  def self.handle_join(user, tracking_token)
    tracked_link = TrackedLink.find_by_tracking_token(tracking_token)
    TrackedLink.increment_counter(:join_count, tracked_link.id)
  end


  def self.generate_token
    if @@test_token
      return @@test_token
    else
      return ActiveSupport::SecureRandom.hex(8)
    end
  end



  # hack to allow testing of token collisions
  def self.set_test_token(token)
    @@test_token = token
  end

  # returns the short tracked link that gets resolved
  # by lookup to tracked_links table
  def tracked_url
    return tracked_link_url(self.tracking_token)
  end

  # returns full url with tracking token added to query string
  # useful in cases (like links in emails) where you need the url to look
  # more like the original
  def long_tracked_url
      if self.url.include? "?"
        return "#{self.url}&ref=#{self.tracking_token}"
      else
        return "#{self.url}?ref=#{self.tracking_token}"
      end
  end


  # this is a bit of a hack so that we can differentiate
  #  - invitation.email.click
  #  - invitation.photo-share.click
  #  - invitation.album-share.click
  def click_event_name
      if self.shared_to == TrackedLink::SHARED_TO_EMAIL && self.type != TrackedLink::TYPE_INVITATION
        return "invitation.#{self.type}.click"
      else
        return "invitation.#{self.shared_to}.click"
      end
  end

  # this is a bit of a hack so that we can differentiate
  #  - invitation.email.join
  #  - invitation.photo-share.join
  #  - invitation.album-share.join
  def join_event_name
    if self.shared_to == TrackedLink::SHARED_TO_EMAIL && self.type != TrackedLink::TYPE_INVITATION
      return "invitation.#{self.type}.join"
    else
      return "invitation.#{self.shared_to}.join"
    end

  end


end