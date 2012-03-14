class IdentitiesController < ApplicationController
  ssl_required :zz_api_update

  # Returns the specified identity object for the current user
  #
  # This is called as:
  #
  # /zz_api/identities/:service_name
  #
  # for example: /zz_api/identities/:facebook
  #
  #
  # Returns identity object in the following form. For
  # secuirty, 'credentials' is replaced with true/false
  #
  #   {
  #      "name":null,
  #      "identity_source":"facebook",
  #      "created_at":"2011-12-05T15:29:01-08:00",
  #      "updated_at":"2011-12-05T15:29:01-08:00",
  #      "id":109900075691,
  #      "user_id":1149,
  #      "type":"FacebookIdentity",
  #      "last_import_all":null,
  #      "credentials":false,
  #      "last_contact_refresh":null
  #   }
  def zz_api_identity
    return unless require_user

    zz_api do
      identity = current_user.identities.find(:first, :conditions => {:identity_source => params[:service_name]})
      attrs = identity.attributes
      attrs['credentials'] = !attrs['credentials'].blank?
      attrs
    end
  end





  # Returns all the identity objects for the current user
  #
  # This is called as:
  #
  # /zz_api/identities
  #
  # returns array of identity objects for the current
  # user in the following form. For
  # secuirty, 'credentials' is replaced with true/false
  #
  # [
  #   {
  #      "name":null,
  #      "identity_source":"facebook",
  #      "created_at":"2011-12-05T15:29:01-08:00",
  #      "updated_at":"2011-12-05T15:29:01-08:00",
  #      "id":109900075691,
  #      "user_id":1149,
  #      "type":"FacebookIdentity",
  #      "last_import_all":null,
  #      "credentials":false,
  #      "last_contact_refresh":null
  #   },
  #   ...
  # ]
  def zz_api_identities
    return unless require_user

    zz_api do
      results = []

      current_user.identities.each do |identity|
        attrs = identity.attributes
        attrs['credentials'] = !attrs['credentials'].blank?
        results << attrs
      end

      results
    end
  end

  # Checks for existence and validity of the credentials for multiple services.
  #
  # This is called as (POST):
  #
  # /zz_api/identities/validate
  #
  # Operates in the context of the current logged in user
  #
  # Input array of services:
  #
  # {
  #   :services => [service1, service2, ...]  - array of service names to check
  # },
  #
  # Returns the hash of validation info.
  #
  # {
  #   :service1 => {
  #     :credentials_valid => true if the credentials validated properly, false otherwise
  #       We only currently check valid credentials for facebook & twitter, for others we always return true
  #     :has_credentials => true if the credentials have actually been set, use credentials_valid to see if
  #       they are also valid.
  #   },
  #   ...
  # }
  def zz_api_validate_credentials
    zz_api do
      user = current_user

      results = {}
      services = params[:services]
      # validate all the service names given
      services.each do |service|
        raise ZZAPIError.new('The service name is not valid') unless Identity.is_valid_service_name?(service)

        identity = user.send("identity_for_#{service}".to_sym)
        verified = identity.verify_credentials
        results[service] = {
            :credentials_valid => verified,
            :has_credentials => identity.has_credentials?
        }
      end
      results
    end
  end

  # Sets the credentials for a given identity.
  #
  # This is called as (POST - https):
  #
  # /zz_api/identities/update
  #
  # Operates in the context of the current logged in user
  #
  # Input:
  #
  # {
  #   :service => the service you are setting the identity for (facebook,twitter,etc) - must be lower case,
  #   :credentials => the api token for the identity.  This can be nil if you want to clear the token.  In
  #     this case we will clear the token and return false for credentials_valid.
  # }
  #
  # We validate and then set the identity.  If token cannot be verified we do not
  # set the token and return false for credentials_valid.
  #
  # Returns the validation info.
  #
  # {
  #   :credentials_valid => true if the credentials validated properly, false otherwise
  #     We only currently check valid credentials for facebook & twitter, for others we always return true
  # }
  def zz_api_update
    return unless require_user

    zz_api do
      service = params[:service]
      credentials = params[:credentials]

      raise ZZAPIError.new('The service name is not valid') unless Identity.is_valid_service_name?(service)

      user = current_user
      identity = user.send("identity_for_#{service}".to_sym)
      identity.credentials = credentials
      if credentials.nil?
        verified = false
        identity.save
      else
        verified = identity.verify_credentials
        identity.save if verified
      end

      result = {
          :credentials_valid => verified
      }
    end
  end
end
