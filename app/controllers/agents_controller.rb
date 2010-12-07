class AgentsController < ApplicationController
  #before_filter :oauth_required

  def index
    @agents = Agent.find_all_by_user_id(current_user.id, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
  end

  def info
    render :json=> "Statistics received. Thank you", :status=>200 and return #TODO:Do something with the statistics
  end

  def check
    render :json => "ERROR: Version argument missing" ,:status => 400 and return unless params[:version]
    render :json => "ERROR: Platform argument missing", :status => 400 and return unless params[:platform]
    render :json => "ERROR: Platform Version argument missing", :status => 400 and return unless params[:platform_version]
   
    agent = ZANGZING_AGENT_CONFIG['agents'][params[:version]] ||ZANGZING_AGENT_CONFIG['agents']['default']
    platform = agent[params[:platform]] || agent['default']
    response = platform[params[:platform_version]] || platform['default']

    render :text => response.to_json;
  end
end
