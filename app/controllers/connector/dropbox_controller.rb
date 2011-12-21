class Connector::DropboxController < Connector::ConnectorController
  require 'dropbox'

  def self.api_from_identity(identity)
    raise InvalidToken unless identity.credentials
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

  def self.make_url(entry_path, options = {})
      root = options.delete(:root) || 'files'
      path = entry_path.sub(/^\//, '')
      rest = Dropbox.check_path(path).split('/')
      rest << { :ssl => false }
      rest.last.merge! options
      Dropbox.api_url(root, 'dropbox', *rest)
  end

  def self.make_signed_url(access_token, entry_path, options = {})
      url = make_url(entry_path, options)
      request_uri = URI.parse(url)
      signed_url = "#{request_uri.scheme}://#{request_uri.host}"
      access_token.consumer.request(:get, url, access_token, {:scheme => :query_string}) do |http_request|
        signed_url << http_request.path
        :done
      end
      signed_url
  end

  def self.extract_auth_headers(access_token, entry_path, options = {})
      url = make_url(entry_path, options)
      auth_headers = nil
      access_token.consumer.request(:get, url, access_token) do |http_request|
      auth_headers = http_request.instance_variable_get(:@header).inject({}) do |hsh,e|
        hsh[e.first] = e.last.first
        hsh
      end
        :done
      end
      auth_headers
  end
  
end
