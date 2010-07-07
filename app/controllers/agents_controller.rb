class AgentsController
   before_filter :require_user


  def new

  end

  def create
=begin
     @user = current_user
     @agent = user.create_agent(params[:agent_id])
     respond_to do |format|
        format.json do

        end
     end
=end

  end
end