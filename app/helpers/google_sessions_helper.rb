


module GoogleSessionsHelper


  def get_google_token
    identity = current_user.identity_for_gmail
    if(! identity)
      return nil
    end

    return identity.credentials
  end

  def save_google_token(gmail_address, upgraded_token)
    identity = current_user.identity_for_gmail
    identity.name = gmail_address
    identity.credentials = upgraded_token
    identity.save
  end

  def delete_google_token
    identity = current_user.identity_for_gmail
    identity.credentials = nil
    identity.save
  end

end