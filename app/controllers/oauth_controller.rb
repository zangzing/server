class OauthController < ApplicationController
  ssl_allowed :request_token, :authorize, :agentauthorize, :access_token, :revoke, :invalidate, :capabilities, :test_request, :test_session


  before_filter :require_user, :only => [:authorize,:revoke, :agentauthorize]
  before_filter :oauth_required, :only => [:invalidate,:capabilities, :test_request, :test_session]
  before_filter :verify_oauth_consumer_signature_agent, :only => [:request_token]
  before_filter :verify_oauth_request_token, :only => [:access_token]
  skip_before_filter :verify_authenticity_token, :only=>[:request_token, :access_token, :invalidate, :test_request, :test_session]



  def request_token
    @token = current_client_application.create_request_token
    if @token
      render :text => @token.to_query
    else
      render :nothing => true, :status => 401
    end
  end

  def authorize
    @token = ::RequestToken.find_by_token params[:oauth_token]
    unless @token
      render :action=>"authorize_failure"
      return
    end

    unless @token.invalidated?
      if request.post?
        if user_authorizes_token?
          @token.authorize!(current_user)
          if @token.oauth10?
            @redirect_url = params[:oauth_callback] || @token.client_application.callback_url
          else
            @redirect_url = @token.oob? ? @token.client_application.callback_url : @token.callback_url
          end

          if @redirect_url
            if @token.oauth10?
              redirect_to "#{@redirect_url}?oauth_token=#{@token.token}"
            else
              redirect_to "#{@redirect_url}?oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}"
            end
          else
            render :action => "authorize_success"
          end
        else
          @token.invalidate!
          render :action => "authorize_failure"
        end
      end
    else
      render :action => "authorize_failure"
    end
  end


  def agentauthorize
    @token = RequestToken.find_by_token params[:oauth_token]
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



  def access_token
    @token = current_token && current_token.exchange!
    if @token
      @token = @token.get_agent_token( params['agent_id'], request.headers['HTTP_X_ZZ_AGENT_VER'] )
      render :text => @token.to_query
    else
      render :nothing => true, :status => 401
    end
  end

  def revoke
    @token = current_user.tokens.find_by_token params[:token]
    if @token
      @token.invalidate!
      flash[:notice] = "You've revoked the token for #{@token.client_application.name}"
    end
    redirect_to oauth_clients_url
  end

  # Invalidate current token
  def invalidate
    current_token.invalidate!
    head :status=>410
  end

  # Capabilities of current_token
  def capabilities
    if current_token.respond_to?(:capabilities)
      @capabilities=current_token.capabilities
    else
      @capabilities={:invalidate=>url_for(:action=>:invalidate)}
    end

    respond_to do |format|
      format.json {render :json=>@capabilities}
      format.xml {render :xml=>@capabilities}
    end
  end

  def test_request
    render :text => params.collect{|k,v|"#{k}=#{v}"}.join("&")
  end

  # requires a valid oauth call with a session hash
  # validates that the token owner and the session hash match
  def test_session
    # The user got here by authenticating via OAuth not session cookie, but the cookie was also sent to make
    # sure that the interactive call from the browser comes from the owner of the token.
    # current_user in this call is set by the OAuth library
    # curent_user_session is set by authlogic from the cookie
    # if current_user matches the user owner of the cooke then we return 200
    if( current_token )
      @user = current_token.user
      if current_user_session && current_user_session.valid? && current_user?(current_user_session.user)
        current_token.update_attribute( :agent_version,  request.headers['HTTP_X_ZZ_AGENT_VER'] )
        render :text => "Valid Session", :status => 200
      else
        render :text => "Session/Token Missmatched. The signed-in user cannot use this agent", :status => 412
      end
    else
      render :text => "Access Token No Longer Valid, Please re-authorize.", :status => 417
    end
  end

  protected

# Override this to match your authorization page form
  def user_authorizes_token?
    params[:authorize] == '1'
  end

  def verify_oauth_consumer_signature_agent
     unless verify_oauth_consumer_signature
        logger.warn "WARNING: An OAuth Client Application Request Failed. It Maybe the ZangZing Agent!. Was the database seeded with the Agents Consumer Key (rake db:seed)?"
     end
  end


  def verify_oauth_consumer_signature
    begin
      valid = ClientApplication.verify_request(request) do |request_proxy|
        @current_client_application = ClientApplication.find_by_key(request_proxy.consumer_key)

        # Store this temporarily in client_application object for use in request token generation
        @current_client_application.token_callback_url=request_proxy.oauth_callback if request_proxy.oauth_callback

        # return the token secret and the consumer secret
        [nil, @current_client_application.secret]
      end
    rescue
      valid=false
    end

    invalid_oauth_response unless valid
    valid
  end
  
  def verify_oauth_request_token
    verify_oauth_signature && current_token.is_a?(::RequestToken)
  end

  def invalid_oauth_response(code=401,message="Invalid OAuth Request")
    render :text => message, :status => code
  end


  # Implement this for your own application using app-specific models
  def verify_oauth_signature
    begin
      valid = ClientApplication.verify_request(request) do |request_proxy|
        self.current_token = ClientApplication.find_token(request_proxy.token)
        if self.current_token.respond_to?(:provided_oauth_verifier=)
          self.current_token.provided_oauth_verifier=request_proxy.oauth_verifier
        end
        # return the token secret and the consumer secret
        [(current_token.nil? ? nil : current_token.secret), (current_client_application.nil? ? nil : current_client_application.secret)]
      end
      # reset @current_user to clear state for restful_...._authentication
      @current_user = nil if (!valid)
      valid
    rescue
      false
    end
  end

end
