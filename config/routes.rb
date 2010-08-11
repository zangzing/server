ActionController::Routing::Routes.draw do |map|

  map.resources :users, :shallow => true  do | user |
#      user.resources :albums, :name_prefix => "user_" do | album |
#        album.resources :photos, :name_prefix => "album_",:member => { :upload => :put }
#        album.resources :shares, :name_prefix => "album_"
#      end
#      user.resources :oauth_clients, :name_prefix => "user_"
  end



  # albums
  map.with_options :controller => :albums do |albums|
    albums.user_albums        '/users/:user_id/albums.',     :action=>"index",  :conditions=>{ :method => :get }
    albums.create_user_album  '/users/:user_id/albums.',     :action=>"create", :conditions=>{ :method => :post }
    albums.new_user_album     '/users/:user_id/albums/new.', :action=>"new",    :conditions=>{ :method => :get }
    albums.edit_album         '/albums/:id/edit.',           :action=>"edit",   :conditions=>{ :method => :get }
    albums.album              '/albums/:id.',                :action=>"show",   :conditions=>{ :method => :get }
    albums.update_album       '/albums/:id.',                :action=>"update", :conditions=>{ :method => :put }
    albums.delete_album       '/albums/:id.',                :action=>"destroy",:conditions=>{ :method => :delete }
    albums.upload             '/albums/:id/upload',          :action=>"upload", :conditions=>{ :method => :get }
  end


  # photos
  map.with_options :controller => :photos do |photos|
    photos.album_photos                '/albums/:album_id/photos.',                 :action=>'index',           :conditions => { :method => :get }
    photos.create_album_photo          '/albums/:album_id/photos.',                 :action=>'create',          :conditions => { :method => :post }
    photos.create_multiple_album_photo '/albums/:album_id/photos/create_multiple.', :action=>'create_multiple', :conditions => { :method => :post }
    photos.new_album_photo             '/albums/:album_id/photos/new.',             :action=>'new',             :conditions => { :method => :get }
    photos.upload_photo                '/photos/:id/upload.',                       :action=>'upload',          :conditions => { :method => :put }
    photos.edit_photo                  '/photos/:id/edit.',                         :action=>'edit',            :conditions => { :method => :get }
    photos.update_photo                '/photos/:id/edit.',                         :action=>'update',          :conditions => { :method => :put }
    photos.destroy_photo               '/photos/:id.',                              :action=>'destroy',         :conditions => { :method => :delete }
    photos.photo                       '/photos/:id.',                              :action=>'show',            :conditions => { :method => :get }
    photos.agent_photos                '/agents/:agent_id/photos.',                 :action=>'agentindex',      :conditions=>{ :method => :get }
  end

  #root  the root of zangzing -- just remember to delete public/index.html.
  map.root :controller => "pages", :action => 'home'



  # OAuth to authenticate and authorize agents
  #map.resources :oauth_clients
  #map.oauth          '/oauth',               :controller=>'oauth_clients',:action=>'index'
  map.agents         '/users/:id/agents',    :controller=>'agents',:action=>'index'
  map.authorize      '/oauth/authorize',     :controller=>'oauth',:action=>'authorize'
  map.agentauthorize '/oauth/agentauthorize',:controller=>'oauth',:action=>'agentauthorize'
  map.revoke         '/oauth/revoke',        :controller=>'oauth',:action=>'revoke'
  map.request_token  '/oauth/request_token', :controller=>'oauth',:action=>'request_token'
  map.access_token   '/oauth/access_token',  :controller=>'oauth',:action=>'access_token'
  map.test_request   '/oauth/test_request',  :controller=>'oauth',:action=>'test_request'
  map.test_session   '/oauth/test_session',  :controller=>'oauth',:action=>'test_session'

  # LOGIN
  map.resources :user_sessions, :only => [:new, :create, :destroy]
  map.signin '/signin', :controller => 'user_sessions', :action => 'new'
  map.signout '/signout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :password_resets, :only => [:new, :edit, :create, :update]

  # Static pages
  map.contact '/contact', :controller => 'pages', :action => 'contact'
  map.about   '/about',   :controller => 'pages', :action => 'about'
  map.help    '/help',    :controller => 'pages', :action => 'help'
  map.signup '/signup',   :controller => 'users', :action => 'new'

  #Flickr
  map.with_options :controller => :flickr_sessions do |flickr|
    flickr.new_flickr_session     '/flickr/sessions/new', :action  => 'new'
    flickr.create_flickr_session  '/flickr/sessions/create', :action  => 'create'
    flickr.destroy_flickr_session '/flickr/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :controller => :flickr_photos do |flickr|
    flickr.flickr_photos '/flickr/folders/:set_id/photos.:format', :action  => 'index'
    flickr.flickr_photo  '/flickr/folders/:set_id/photos/:photo_id.:size', :action  => 'show'
    flickr.flickr_photo_action  '/flickr/folders/:set_id/photos/:photo_id/:action'
  end

  map.with_options :controller => :flickr_folders do |flickr|
    flickr.flickr_folders '/flickr/folders.:format', :action  => 'index'
    flickr.flickr_folder_action '/flickr/folders/:set_id/:action.:format'
  end

  #Kodak
  map.with_options :controller => :kodak_sessions do |kodak|
    kodak.new_kodak_session     '/kodak/sessions/new', :action  => 'new'
    kodak.create_kodak_session  '/kodak/sessions/create', :action  => 'create'
    kodak.destroy_kodak_session '/kodak/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :controller => :kodak_photos do |kodak|
    kodak.kodak_photos '/kodak/folders/:kodak_album_id/photos.:format', :action  => 'index'
    kodak.kodak_photo  '/kodak/folders/:kodak_album_id/photos/:photo_id.:size', :action  => 'show'
    kodak.kodak_photo_action '/kodak/folders/:kodak_album_id/photos/:photo_id/:action'
  end

  map.with_options :controller => :kodak_folders do |kodak|
    kodak.kodak_folders '/kodak/folders.:format', :action  => 'index'
    kodak.kodak_folder_action '/kodak/folders/:kodak_album_id/:action.:format'
  end

  #Facebook
  map.with_options :controller => :facebook_sessions do |fb|
    fb.new_facebook_session     '/facebook/sessions/new', :action  => 'new'
    fb.create_facebook_session  '/facebook/sessions/create', :action  => 'create'
    fb.destroy_facebook_session '/facebook/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :controller => :facebook_photos do |fb|
    fb.facebook_photos '/facebook/folders/:fb_album_id/photos.:format', :action  => 'index'
    fb.facebook_photo  '/facebook/folders/:fb_album_id/photos/:photo_id.:size', :action  => 'show'
    fb.facebook_photo_action '/facebook/folders/:fb_album_id/photos/:photo_id/:action'
  end

  map.with_options :controller => :facebook_folders do |fb|
    fb.facebook_folders '/facebook/folders.:format', :action  => 'index'
    fb.facebook_folder_action '/facebook/folders/:fb_album_id/:action.:format'
  end

  map.with_options :controller => :facebook_posts do |fb|
    fb.facebook_posts           '/facebook/posts.:format',    :action  => 'index'
    fb.create_facebook_post  '/facebook/posts/create',     :action  => 'create'
  end

  #SmugMug
  map.with_options :controller => :smugmug_sessions do |fb|
    fb.new_smugmug_session     '/smugmug/sessions/new', :action  => 'new'
    fb.create_smugmug_session  '/smugmug/sessions/create', :action  => 'create'
    fb.destroy_smugmug_session '/smugmug/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :controller => :smugmug_photos do |fb|
    fb.smugmug_photos '/smugmug/folders/:sm_album_id/photos.:format', :action  => 'index'
    fb.smugmug_photo  '/smugmug/folders/:sm_album_id/photos/:photo_id.:size', :action  => 'show'
    fb.smugmug_photo_action '/smugmug/folders/:sm_album_id/photos/:photo_id/:action'
  end

  map.with_options :controller => :smugmug_folders do |fb|
    fb.smugmug_folders '/smugmug/folders.:format', :action  => 'index'
    fb.smugmug_folder_action '/smugmug/folders/:sm_album_id/:action.:format'
  end

  #ShutterFly
  map.with_options :controller => :shutterfly_sessions do |sf|
    sf.new_shutterfly_session     '/shutterfly/sessions/new', :action  => 'new'
    sf.create_shutterfly_session  '/shutterfly/sessions/create', :action  => 'create'
    sf.destroy_shutterfly_session '/shutterfly/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :controller => :shutterfly_photos do |sf|
    sf.shutterfly_photos '/shutterfly/folders/:sf_album_id/photos.:format', :action  => 'index'
    sf.shutterfly_photo  '/shutterfly/folders/:sf_album_id/photos/:photo_id.:size', :action  => 'show'
    sf.shutterfly_photo_action '/shutterfly/folders/:sf_album_id/photos/:photo_id/:action'
  end

  map.with_options :controller => :shutterfly_folders do |sf|
    sf.shutterfly_folders '/shutterfly/folders.:format', :action  => 'index'
    sf.shutterfly_folder_action '/shutterfly/folders/:sf_album_id/:action.:format'
  end

  #Google
  map.with_options :controller => :google_sessions do |g|
    g.new_google_session     '/google/sessions/new', :action  => 'new'
    g.create_google_session  '/google/sessions/create', :action  => 'create'
    g.destroy_google_session '/google/sessions/destroy', :action  => 'destroy'
  end
  map.google_contacts '/google/contacts/:action', :controller => 'google_contacts'

  #LocalContacts importer
  map.local_contacts '/local/contacts/:action', :controller => 'local_contacts'


end
