class Connector::FacebookFoldersController < Connector::FacebookController
  
  def self.list_folders(api_client, params)
    target = params[:target]
    unless target
      call_with_error_adapter do #A call with short response just to validate token
        api_client.get('', :domain => 'www.facebook.com')
      end
      fb_root = [
        {
          :name => 'My Albums', :type => 'folder', :id => 'my-albums',
          :open_url => facebook_folders_path(:target => 'me/albums', :format => 'json'), :add_url => nil
        },
        {
          :name => "My Friends' Albums", :type => 'folder', :id => 'my-friends',
          :open_url => facebook_folders_path(:target => 'me/friends', :format => 'json'), :add_url => nil
        },
        {
          :name => 'Photos of Me', :type => 'folder', :id => 'tagged-with-me',
          :open_url => facebook_photos_path('me', :format => 'json'), :add_url => facebook_folder_action_path(:fb_album_id =>'me', :action => 'import', :format => 'json')
        }
      ]
      @folders = fb_root
    else
      album_list = call_with_error_adapter do
        api_client.get(target, :limit => 1000)
      end

      #album_list.reject! { |a| a[:type] == 'profile' } #Remove 'Profile Pictures'
      unless album_list.empty?
        if album_list.first[:updated_time]
          begin
            album_list.sort!{|a, b|
              b[:updated_time] <=> a[:updated_time]
            }
          rescue Exception => ex
            # we have seen rare cases where facebook returns bad values and we can't sort
            # in this case, just leave unsorted
            Rails.logger.info small_back_trace(ex)
          end
        end

        if target=='me/friends' #Sort by last names
          begin
            album_list = album_list.sort_by { |friend| friend[:name].split(' ').last }
          rescue Exception => ex
            # we have seen rare cases where facebook returns bad values and we can't sort
            # in this case, just leave unsorted
            Rails.logger.info small_back_trace(ex)
          end
        end


        @folders = album_list.map do |f|
          {
            :name => f[:name] || "Created #{f[:created_time].strftime('%d %b %Y')}",
            :type => "folder",
            :id  =>  f[:id]
          }
        end
        @folders.each do |f|
          f[:add_url] = nil
          if target=='me/friends'
            f[:open_url] = facebook_folders_path(:target => "#{f[:id]}/albums", :format => 'json')
          elsif target.match(/\w+\/albums/)
            f[:open_url] = facebook_photos_path(f[:id], :format => 'json')
            f[:add_url] = facebook_folder_action_path(:fb_album_id =>f[:id], :action => 'import', :format => 'json')
          end
        end
      else
        @folders = []
      end
    end
    JSON.fast_generate(@folders)
  end
  
  def self.import_folder(api_client, params)
    identity = params[:identity]
    photos_list = call_with_error_adapter do
      api_client.get("#{params[:fb_album_id]}/photos", :limit => 1000)
    end

    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )

    photos_list.each do |p|
      photo_url = get_photo_url(p, :full)
      photo = Photo.new_for_batch(current_batch, {
                :id => Photo.get_next_id,
                :user_id=>identity.user.id,
                :album_id => params[:album_id],
                :upload_batch_id => current_batch.id,
                :work_priority => params[:priority] || ZZ::Async::Priorities.import_single_album,
                :caption => p[:name] || '',
                :capture_date => p[:created_time],
                :source_guid => make_source_guid(p),
                :source_thumb_url => get_photo_url(p, :thumb),
                :source_screen_url => get_photo_url(p, :screen),
                :source => 'facebook'
      })
      photo.temp_url = photo_url
      photos << photo
    end

    bulk_insert(photos)
  end

  def self.import_all_folders(api_client, params)
    call_with_error_adapter do #A call with short response just to validate token
      api_client.get('', :domain => 'www.facebook.com')
    end

    identity = params[:identity]
    zz_albums = []
    album_list = call_with_error_adapter do
      api_client.get('me/albums', :limit => 1000)
    end

    unless album_list.empty?
      album_list.each do |fb_album|
        zz_album = create_album(identity, fb_album[:name], params[:privacy])
        zz_albums << {:album_name => zz_album.name, :album_id => zz_album.id}
        fire_async_import_all('import_folder', params.merge(:fb_album_id =>  fb_album[:id], :album_id => zz_album.id))
      end
    end

    identity.last_import_all = Time.now
    identity.save

    JSON.fast_generate(zz_albums)
  end


  def index
    fire_async_response('list_folders')
  end

  def import
    fire_async_response('import_folder')
  end

  def import_all
    fire_async_response('import_all_folders')
  end


end
