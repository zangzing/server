class TrackedLink < ActiveRecord::Base

  belongs_to :user


  TYPE_INVITATION = 'invitation'

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

  def self.handle_visit(tracking_token)
    tracked_link = TrackedLink.find_by_tracking_token(tracking_token)
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
      return ActiveSupport::SecureRandom.base64(8).gsub("/","_").gsub("+","_").gsub("=","_")
    end
  end



  # hack to allow testing of token collisions
  def self.set_test_token(token)
    @@test_token = token
  end


end