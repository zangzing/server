class AgentsController < ApplicationController 
   before_filter :require_user

   def show     
      render :text =>"IT WORKS", :status =>200     
   end

   def create
     @client_application = current_user.client_applications.build({ :name         => params[:name],
                                                                    :url          => params[:url] })
     @client_application.name = "AGENT:"+ @client_application.name
     respond_to do | format |
       format.html do
         if @client_application.save
           flash[:notice] = "Registered the information successfully"
           redirect_to :action => "show", :id => @client_application.id
         else
           render :action => "OauthClientsController/new"
         end
       end
       format.json do
         if @client_application.save
           render :json => @client_application
         else
           render :json => @client_application.errors, :status=>500
         end
       end
     end
   end
end