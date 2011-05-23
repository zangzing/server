class Connector::DropboxController < Connector::ConnectorController


  def self.api_from_identity(identity)
    Dropbox::Session.deserialize(identity.credentials).tap {|api| api.mode = :metadata_only }
  end

  def self.moderate_exception(exception)
    if exception.kind_of?(Dropbox::APIError)
      InvalidToken.new((JSON.parse(exception.body)['error'] rescue exception.response.message))
    end
  end


protected

  def service_login_required
    #Unused for now, need to wipe along with others
    true
  end

  def service_identity
    @service_identity ||= current_user.identity_for_dropbox
  end

  def dropbox_api
    @api ||= if session_data
      Dropbox::Session.deserialize(session_data)
    else
      Dropbox::Session.new(DROPBOX_API_KEYS[:api_key], DROPBOX_API_KEYS[:shared_secret])
    end
    @api.mode = :metadata_only
    @api
  end

  def dropbox_api=(api)
    @api = api if api.is_a?(Dropbox::Session) || api.is_a?(NilClass)
    @api.mode = :metadata_only if @api
  end

  def session_data
    if service_identity.credentials
      service_identity.credentials
    elsif @api
      @api.serialize
    end
  end

  def self.make_source_guid(url)
    "dropbox_"+Photo.generate_source_guid(url)
  end

end
