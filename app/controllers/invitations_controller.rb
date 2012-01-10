class InvitationsController < ApplicationController

  def invite_friends
    return unless require_user

    @invite_url_for_copy_paste = Invitation.get_invitation_link_for_copy_paste(current_user)
  end


  def show
    redirect_to join_url
  end

end