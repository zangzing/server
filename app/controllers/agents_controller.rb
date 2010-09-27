class AgentsController < ApplicationController
  before_filter :require_user

  def index
    @agents = Agent.find_all_by_user_id(current_user.id, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
  end

  def info
    render :json=> "Statistics received. Thank you", :status=>200 and return #TODO:Do something with the statistics
  end
end