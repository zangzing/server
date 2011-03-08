class ContributorsController < ApplicationController
  before_filter :require_user
  layout false

  def new
    @album = current_user.albums.find(params[:album_id])
  end

  # Creates contributor records for the album.
  # It expects a comma separated list of ids and email addresses
  # id:: Ids in the list are  *Contact* ids
  # email:: Are emails typed by the user and :TODO should be added to the ZangZing contacts
  #
  # Contributors are stored in the Albums contributor acl. The values in the acl
  # maybe the user_id of the contributor or the email address of the contributor if the
  # contributor is not a user.
  # NOTE:: _This method expects Contact ids or emails_

  def acl_create
    fetch_album

    if params[:contact_list].nil?
      flash[:error] = "contact_list parameter not present. Unable to add contributors"
      render :nothing =>true, :status => 404 and return
    end

    #split the comma seprated list into array removing any spaces before or after commma
    ids = params[:contact_list].split(/\s*,\s*/)

    #create a contributor for each id or email, save error ids in error_ids array
    error_ids = []
    ids.each do | id_or_email|
        contact = Contact.find_by_id( id_or_email );
        if contact
          email = contact.address
        elsif ZZ::EmailValidator.validate( id_or_email )
          #there is a slight risk that if a user was created with an invalid email we would not match it here
          email = id_or_email
        else
          error_ids << email
          next  #its neither a contact id nor a valid email. add to errors and go to next itreration
        end
        @album.add_contributor( email )
    end

    if error_ids.length > 0;
      flash[:error] = "Unable to add these #{error_ids.join(',')} contributors"
      render :nothing =>true, :status => 400 and return
    end

    flash[:notice] = "Contributors added"
    render :nothing => true, :status => 200
  end

  def acl_index
    fetch_album
    @acl AlbumACL.new( @album.id )
    #get list of acls for this album
    #iterate the list and get the user name for those tuples wher the id is a user_id
    

  end


  def create
    @album = current_user.albums.find(params[:album_id])
    if @album.nil?
      flash[:error] = "Album not found. Unable to add contributors"
      respond_to do |format|
        format.html  { render :action => 'new' and return }
        format.json { render :json =>{:status => 404, :flash => flash } and return }
      end
    else
      begin
        Contributor.factory( @album, params[:email_share][:to])
        @album.save!
      rescue ActiveRecord::RecordInvalid => invalid
        respond_to do |format|
          format.html  { redirect_to new_album_contributors_url(@album)   }
          format.json  { errors_to_headers( invalid.record )
                         render :json => "", :status => 400 and return}
        end
      end    

      flash[:notice] = "The contributors were added to your album"
      respond_to do |format|
          format.html  { redirect_to album_url(@album)   }
          format.json { render :json => "", :status => 200 and return }
       end
    end
  end

  def index
    @album = current_user.albums.find(params[:album_id])
    if @album.nil?
      flash[:error] = "Album not found. Unable to display contributors"
      render :action =>'new'
    end
    @contributors = @album.contributors
 end

  def destroy
    @contributor = Contributor.find( params[:id] )
    if @contributor.nil?
      flash[:error] ="Contributor with id=#{params[:id]} not found."
      render :status => 404 and return
    end
    if current_user == @contributor.album.user || current_user.admin?
      @contributor.destroy
      flash[:notice] = "Contributor deleted"
      render and return
    end
    flash[:error] ="Only album owners and admins can delete contributors."
    render :status => 500 and return        
  end

  protected

  def fetch_album
     @album = current_user.albums.find_by_id(params[:album_id]) #use find_by_id to avoid exception if not found
    if @album.nil?
      flash[:error] = "Album not found. Unable to create contributors for album"
      render :nothing =>true, :status => 404 and return
    end
  end

end
