class Admin::EmailsController < Admin::AdminController
  def index
    @emails = Email.find(:all)
    @page = 'email'
  end

  def update
    @email = Email.find(params[:id])
    if @email.update_attributes( params[:email])
      flash[:notice] = "Email Template Updated and In Production now!"
      redirect_to :action => :index and return
    end
    flash[:error] = "Unable to update email template"
    redirect_to :action => :index and return
  end

end
