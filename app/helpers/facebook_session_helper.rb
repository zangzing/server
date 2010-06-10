module FacebookSessionHelper


  def get_facebook_token
    identity = current_user.identity_for_facebook
    if(! identity)
      return nil
    end

    return identity.credentials
  end

  def save_facebook_token(facebook_name, upgraded_token)
    identity = current_user.identity_for_facebook
    identity.name = facebook_name
    identity.credentials = upgraded_token
    identity.save
  end

  def delete_facebook_token
    identity = current_user.identity_for_facebook
    identity.credentials = nil
    identity.save
  end
end