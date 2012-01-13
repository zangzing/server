class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :invited_user, :class_name => "User", :foreign_key => "invited_user_id"

  belongs_to :tracked_link

  STATUS_COMPLETE = 'complete'
  STATUS_PENDING = 'pending'


  def self.send_invitation_to_email(from_user, to_address)

    invitation = create_invitation_for_email(from_user, to_address)

    invitation_url = "#{get_invitation_url()}?ref=#{invitation.tracked_link.tracking_token}"

    ZZ::Async::Email.enqueue(:invite_to_join, from_user.id, to_address, invitation_url)

  end


  def self.create_invitation_for_email(from_user, to_address)
    tracked_link = TrackedLink.create_tracked_link(from_user, get_invitation_url, TrackedLink::TYPE_INVITATION, TrackedLink::SHARED_TO_EMAIL, shared_to_address=to_address)
    invitation = Invitation.new
    invitation.tracked_link = tracked_link
    invitation.user = from_user
    invitation.status = Invitation::STATUS_PENDING
    invitation.save!

    return invitation
  end

  def self.get_invitation_link_for_facebook(from_user)
    tracked_link = TrackedLink.create_tracked_link(from_user, get_invitation_url, TrackedLink::TYPE_INVITATION, TrackedLink::SHARED_TO_FACEBOOK)
    return "#{get_invitation_url()}?ref=#{tracked_link.tracking_token}"
  end

  def self.get_invitation_link_for_twitter(from_user)
    tracked_link = TrackedLink.create_tracked_link(from_user, get_invitation_url, TrackedLink::TYPE_INVITATION, TrackedLink::SHARED_TO_TWITTER)
    return "#{get_invitation_url()}?ref=#{tracked_link.tracking_token}"
  end

  def self.get_invitation_link_for_copy_paste(from_user)
    tracked_link = TrackedLink.create_tracked_link(from_user, get_invitation_url, TrackedLink::TYPE_INVITATION, TrackedLink::SHARED_TO_COPY_PASTE)
    return "#{get_invitation_url()}?ref=#{tracked_link.tracking_token}"
  end

  def self.handle_join_from_invitation(new_user, tracking_token)
    tracked_link = TrackedLink.find_by_tracking_token(tracking_token)

    # for emailed invitations, we created the invitation record up front.
    # for the rest, we don't create until a user actually joins
    if tracked_link.shared_to != TrackedLink::SHARED_TO_EMAIL
      invitation = Invitation.new
      invitation.tracked_link = tracked_link
      invitation.user = tracked_link.user
    else
      invitation = Invitation.find_by_tracked_link_id(tracked_link.id)
    end

    invitation.status = Invitation::STATUS_COMPLETE
    invitation.invited_user = new_user
    invitation.save!


    # can the user use any extra storage?
    can_use_bonus_storage = invitation.user.bonus_storage < User::MAX_BONUS_MB


    # give the bonus storage (do it atomically)
    User.update_counters invitation.user.id, :bonus_storage => User::BONUS_STORAGE_MB_PER_INVITE
    User.update_counters invitation.invited_user.id, :bonus_storage => User::BONUS_STORAGE_MB_PER_INVITE


    ZZ::Async::Email.enqueue(:joined_from_invite, invitation.id, can_use_bonus_storage)


    return invitation
  end


private

  def self.get_invitation_url
    Rails.application.routes.url_helpers.invitation_url(:host=>Server::Application.config.application_host)
  end

end