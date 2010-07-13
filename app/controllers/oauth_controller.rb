require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController

  before_filter :login_or_oauth_required, :only => [:test_session]  
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

     def test_session
        logger.debug "The params hash in test_session is #{params.inspect}"
        if( current_token )
          @user = current_token.user
          if( @user and  @user.persistence_token+"::"+@user.id.to_s() == params[:session] )
            render :text => "Valid Session", :status => 200
          else
            render :text => "Session/Token Missmatched. The signed-in user cannot use this agent", :status => 401
          end
        else
          render :text => "Access Token No Longer Valid, Please re-authorize.", :status => 401
        end
     end

  
end
