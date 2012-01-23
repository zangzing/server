class InvitedUserAlreadyExists < StandardError
  def initialize(email)
    super('User with email already exists')
    @email = email
  end

  def email
    @email
  end

end

class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :invited_user, :class_name => "User", :foreign_key => "invited_user_id"

  belongs_to :tracked_link

  STATUS_COMPLETE = 'complete'
  STATUS_COMPLETE_BY_OTHER = 'complete-by-other'
  STATUS_PENDING = 'pending'

  def self.create_and_send_invitation(from_user, to_address)

    user = User.find_by_email(to_address)

    if user && !user.automatic?
      raise InvitedUserAlreadyExists.new(to_address)
    end

    invitation = from_user.sent_invitations.find_by_email(to_address)
    if invitation
      # if user has already sent invite to this email, then just
      # send a reminder
      send_invitation_to_email(invitation)
    else
      # otherwise, create and send new invitation
      invitation = create_invitation_for_email(from_user, to_address)
      send_invitation_to_email(invitation)
    end
  end

  def self.send_reminder(invitation_id)
    invitation = Invitation.find(invitation_id)
    send_invitation_to_email(invitation)
  end

  def self.send_invitation_to_email(invitation)
    if invitation.status != Invitation::STATUS_PENDING
      raise "Sorry, you can't send a reminder for a completed invitation."
    end

    invitation_url = "#{get_invitation_url()}?ref=#{invitation.tracked_link.tracking_token}"

    from_user = invitation.user
    to_address = invitation.tracked_link.shared_to_address

    ZZ::Async::Email.enqueue(:invite_to_join, from_user.id, to_address, invitation_url)

  end

  def self.create_invitation_for_email(from_user, to_address)
    tracked_link = TrackedLink.create_tracked_link(from_user, get_invitation_url, TrackedLink::TYPE_INVITATION, TrackedLink::SHARED_TO_EMAIL, shared_to_address=to_address)
    invitation = Invitation.new
    invitation.tracked_link = tracked_link
    invitation.user = from_user
    invitation.status = Invitation::STATUS_PENDING
    invitation.email = to_address
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


  # if there is token, then look up invitation and 'complete'
  # if no token, then look for invitations with matching email and 'complete'
  # invalidate all other invitations to this email address
  def self.process_invitations_for_new_user(new_user, tracking_token)
    tracked_link = TrackedLink.find_by_tracking_token(tracking_token)

    if tracked_link
      # lookup invitatiob based on tracking token

      # for emailed invitations, we created the invitation record up front.
      # for the rest, we don't create until a user actually joins
      if tracked_link.shared_to != TrackedLink::SHARED_TO_EMAIL
        invitation = Invitation.new
        invitation.tracked_link = tracked_link
        invitation.user = tracked_link.user
      else
        invitation = Invitation.find_by_tracked_link_id(tracked_link.id)
      end
    else

      # find most recent invitation by email
      invitation = Invitation.find(:last, :conditions=>{:email=>new_user.email, :status=>Invitation::STATUS_PENDING})
    end

    if invitation
      invitation.status = Invitation::STATUS_COMPLETE
      invitation.invited_user = new_user
      invitation.save!

      # can the user use any extra storage?
      can_use_bonus_storage = invitation.user.bonus_storage < User::MAX_BONUS_MB


      # give the bonus storage (do it atomically)
      User.update_counters invitation.user.id, :bonus_storage => User::BONUS_STORAGE_MB_PER_INVITE
      User.update_counters invitation.invited_user.id, :bonus_storage => User::BONUS_STORAGE_MB_PER_INVITE

      ZZ::Async::Email.enqueue(:joined_from_invite, invitation.id, can_use_bonus_storage)


      # new user should follow user who invited...
      Like.add(new_user.id, invitation.user.id, Like::USER)
    end


    # invalidate any other invitations for this email address
    Invitation.find(:all, :conditions=>{:email=>new_user.email, :status=>Invitation::STATUS_PENDING}).each do |invalid_invitation|
      invalid_invitation.status = Invitation::STATUS_COMPLETE_BY_OTHER
      invalid_invitation.invited_user = new_user
      invalid_invitation.save
    end


    return invitation
  end


private

  def self.get_invitation_url
    Rails.application.routes.url_helpers.invitation_url(:host=>Server::Application.config.application_host)
  end

end