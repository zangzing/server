class Admin::GuestsController < Admin::AdminController
  skip_before_filter :require_user, :only =>[:create]
  skip_before_filter :require_admin, :only =>[:create]
  oauthenticate :strategies => :two_legged, :interactive => true, :only =>   [ :create ]
  before_filter :require_admin, :only =>[:create]
  
  def index
    @page = 'guests'
    @new_guest = Guest.new()
    @guests = Guest.paginate(:page =>params[:page])
  end

  def show
    @guest = Guest.find(params[:id])
  end


  def create
    @new_guest = Guest.new( :email =>  params[:guest][:email],
                :source => ( params[:guest][:source] ? params[:guest][:source] : 'admin' ) )

    @existing_user = User.find_by_email( @new_guest.email )
    if @new_guest.save
      flash[:notice] = "Guest was added successfully."
      if @existing_user
        @new_guest.user_id = @existing_user.id
        unless @existing_user.active?
          @existing_user.activate!
          @existing_user.deliver_welcome!
        end
        @new_guest.status = 'Active Account'
        @new_guest.save
      else
        ZZ::Async::Email.enqueue( :beta_invite, @new_guest.email ) #Send Beta Email
      end
      respond_to do | format |
        format.html{ redirect_to guests_url and return }
        format.json{ render :json => @new_guest, :status => :ok and return }
      end
    else
      flash[:error] = @new_guest.errors.full_messages
      respond_to do | format |
        format.html{ redirect_to guests_url and return }
        format.json{ render :json => @new_guest.errors, :status => :unprocessable_entity and return }
      end
    end
  end

  def activate
    @guest = Guest.find(params[:id])
    @guest.user.activate!
    @guest.user.deliver_welcome!
    @guest.status = 'Active Account'
    @guest.save
    redirect_to guests_url and return
  end

end
