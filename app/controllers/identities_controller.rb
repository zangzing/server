class IdentitiesController < ApplicationController

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
  #   }
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
end
