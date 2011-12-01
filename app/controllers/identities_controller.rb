class IdentitiesController < ApplicationController

  before_filter :require_user

  def zz_api_identity
    zz_api do
      identity = current_user.identities.find(:first, :conditions => {:identity_source => params[:service_name]})
      attrs = identity.attributes
      attrs
    end
  end

  def zz_api_identities
    zz_api do
      results = []

      current_user.identities.each do |identity|
        attrs = identity.attributes
        attrs[:name] = identity.name
        results << attrs
      end

      results
    end
  end
end
