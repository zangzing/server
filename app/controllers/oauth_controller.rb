require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController

  before_filter :require_user, :only => [:authorize]

  # Override this to match your authorization page form
  # It currently expects a checkbox called authorize
  # def user_authorizes_token?
  #   params[:authorize] == '1'
  # end

     def authorize
        @token = ::RequestToken.find_by_token params[:oauth_token]
        unless @token
          render :nothing => true, :status => 401
          return
        end
        unless @token.invalidated?
           if @token.authorize!(current_user)
              render :text => @token.verifier
           else
              render :nothing => true, :status => 401
           end
        else
          render :nothing => true, :status => 401
        end
        
     end
end
