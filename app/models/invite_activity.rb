class InviteActivity < Activity
  attr_accessible :invite_kind, :album_id, :invited_user_id, :invited_user_email

  #invite types
  CONTRIBUTE = 'contribute'
  VIEW='view'

  serialize :payload, Hash

  def payload
  value = super
  if value.is_a?(Hash)
    value
  else
    self.payload = {}
  end
end

  def album
    @album ||= Album.find_by_id( self.album_id)
  end

  def album_id
    self.payload[:album_id]
  end

  def album_id=( id )
     self.payload[:album_id] = id
  end

  def invited_user_id
    self.payload[:invited_user_id]
  end

  def invited_user
    if( self.invited_user_id )
     @invited_user ||= User.find_by_id( self.invited_user_id )
    else
      nil
    end
  end


  def invited_user_id=( id )
    self.payload[:invited_user_id] = id
  end

  def invited_user_email
       self.payload[:invited_user_email]
  end

    def invited_user_email=( email )
      self.payload[:invited_user_email] = email
    end

  def invite_kind
   self.payload[:invite_kind]
  end

  def invite_kind=( kind )
    self.payload[:invite_kind] = kind
  end

  def payload_valid?
    begin
      return false unless(  self.album )

      if self.invited_user_id
        return false unless( self.invited_user )
        case self.invite_kind
          when CONTRIBUTE
            return true if self.album.contributor?( self.invited_user_id )
          when VIEW
            return true if self.album.viewer?( self.invited_user_id )
        end
      else
       return false unless( self.invited_user_email )
        case self.invite_kind
          when CONTRIBUTE
            return true if self.album.contributor?( self.invited_user_email )
          when VIEW
            return true if self.album.viewer?( self.invited_user_email )
        end
      end
    rescue Exception
      return false
    end
    false
  end

  def display_for?( current_user, view )
    return false unless album
    case album.privacy
      when Album::PUBLIC
        return true if invited_user_id
        return true if invited_user_email && current_user && album.admin?( current_user.id )
      when Album::HIDDEN
        if invited_user_id
          return true if view == ALBUM_VIEW
          return true if current_user &&  album.viewer_in_group?( current_user.id )
        else
          return true if invited_user_email && current_user &&  album.admin?( current_user.id )
        end
      when Album::PASSWORD
        return true if invited_user_id    && current_user &&  album.viewer_in_group?( current_user.id )
        return true if invited_user_email && current_user &&  album.admin?( current_user.id )
    end
    false
  end
end