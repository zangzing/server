class GoogleController < ConnectorController
  require 'gdata'

  before_filter :service_login_required

protected

  def service_login_required
    unless permanent_token
      @permanent_token = service_identity.credentials
      raise InvalidToken unless @permanent_token
      contacts_client.authsub_token = @permanent_token
    end
  end

  def service_identity
    @service_identity ||= current_user.identity_for_google
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
