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

  def self.make_signed_url(access_token, entry_path, options = {})
      root = options.delete(:root) || 'files'
      path = entry_path.sub(/^\//, '')
      rest = Dropbox.check_path(path).split('/')
      rest << { :ssl => false }
      rest.last.merge! options
      url = Dropbox.api_url(root, 'dropbox', *rest)
      request_uri = URI.parse(url)

      http = Net::HTTP.new(request_uri.host, request_uri.port)
      req = Net::HTTP::Get.new(request_uri.request_uri)
      req.oauth!(http, access_token.consumer, access_token, {:scheme => :query_string})
      "#{request_uri.scheme}://#{request_uri.host}#{req.path}"
  end

end
