class Connector::ZangzingController < Connector::ConnectorController

  def service_identity
    @service_identity ||= current_user.identity_for_local
  end

end