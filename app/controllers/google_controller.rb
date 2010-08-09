class GoogleController < ConnectorController
  require 'gdata'

  before_filter :service_login_required

protected

  def service_login_required
    unless permanent_token
      begin
        @permanent_token = token_store.get_token(current_user.id)
        contacts_client.authsub_token = @permanent_token
      rescue => exception
        raise InvalidToken if exception.kind_of?(GData::Client::AuthorizationError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end

  def token_store
    @token_store ||= TokenStore.new(:google)
  end

  def contacts_client
    @client ||= GData::Client::Contacts.new
  end

  def scope
    'http://www.google.com/m8/feeds/'
  end

  def upgrade_access_token!(request_token)
    contacts_client.authsub_token = request_token
    @permanent_token = contacts_client.auth_handler.upgrade()
    contacts_client.authsub_token = @permanent_token
  end
  
  def permanent_token
    @permanent_token
  end

  def permanent_token=(new_token)
    @permanent_token = new_token
    contacts_client.authsub_token = new_token
  end

end
