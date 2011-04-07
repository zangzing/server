class Admin::GuestsController < Admin::AdminController
  def index
    @page = 'guests'
    @new_guest = Guest.new()
    @guests = Guest.paginate(:page =>params[:page])
  end

  def create
    @new_guest = Guest.new( :email =>  params[:guest][:email],
                :source => ( params[:guest][:source] ? params[:guest][:source] : 'admin' ) )
    if @new_guest.save
      redirect_to guests_path, :notice => "Guest Added!"
    else
      flash[:error] = @new_guest.errors.full_messages
      redirect_to guests_path, :error => @new_guest.errors.on(:email)
    end
  end

  def potd_create
    
  end

  def update
  end

end
