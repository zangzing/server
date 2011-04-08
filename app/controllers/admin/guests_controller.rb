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
    if @new_guest.save
      flash[:notice] = "Guest was added successfully."
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

  def update
  end

end
