class AgentsController < ApplicationController
  before_filter :require_user

  def index
    @agents = Agent.where(['oauth_tokens.user_id = ? and oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null',current_user.id])
  end

  def info
    render :json=> "Statistics received. Thank you", :status=>200 and return #TODO:Do something with the statistics
  end
end