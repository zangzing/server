class Connector::YahooController < Connector::ConnectorController
  require "contacts"

  before_filter :service_login_required
  

protected

  def service_login_required
    unless login_data?
      load_login_data!
      raise InvalidToken unless login_data?
    end
    begin
      contact_api
    rescue => e
      raise InvalidCredentials if e.kind_of?(Contacts::AuthenticationError)
    end
  end

  def login_data?
    @login && @password
  end

  def store_login_data(login, password)
    @login = login
    @password = password
    service_identity.update_attribute(:credentials, {:login => @login, :password => @password}.to_yaml)
  end

  def load_login_data!
    return if service_identity.credentials.blank?
    data = YAML.load(service_identity.credentials)
    @login = data[:login].to_s
    @password = data[:password].to_s
  end

  def wipe_login_data!
    @login = nil
    @password = nil
    service_identity.update_attribute(:credentials, nil)
  end

  def contact_api
    @api ||= Contacts::Yahoo.new(@login, @password)
  end

  def service_identity
    @service_identity ||= current_user.identity_for_yahoo
  end

end
