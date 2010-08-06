class FacebookFoldersController < FacebookController

  def index
    album_list = facebook_graph.get('me/albums')
    album_list.reject! { |a| a[:link].include?('aid=-3') } #Remove 'Profile Pictures'
    @folders = album_list.map { |f| {:name => f[:name], :id => f[:id]} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @folders.to_json }
    end
  end

  def import
    photos_list = facebook_graph.get("#{params[:fb_album_id]}/photos")
    photos = []
    photos_list.each do |p|
      photo = Photo.create(:caption => p[:name], :album_id => params[:album_id])
      Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, p[:source]))
      photos << photo
    end

    respond_to do |wants|
      wants.html { @photos = photos }
      wants.json { render :json => photos.to_json }
    end
  end


end
