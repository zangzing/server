ActionController::Routing::Routes.draw do |map|


  # The priority is based upon order of creation: first created -> highest priority.



  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

    map.resources :users, :shallow => true  do | user |
      user.resources :albums, :name_prefix => "user_" do | album |
        album.resources :photos, :name_prefix => "album_",:member => { :upload => :put }
        album.resources :shares, :name_prefix => "album_"
      end
      user.resources :oauth_clients, :name_prefix => "user_" 
    end

    map.album_photo_create_multiple "/albums/:album_id/photos/create_multiple.", :controller => 'photos', :action => 'create_multiple', :conditions => { :method => :post }      


    map.resources :agents   #, :only => [:create, :show]
    map.agent_photos "/agents/:agent_id/photos.", :controller =>'photos', :action => 'agentindex'

    # Oauth installation to authenticate and authorize agents
    map.oauth '/oauth',:controller=>'oauth',:action=>'index'
    map.authorize '/oauth/authorize',:controller=>'oauth',:action=>'authorize'
    map.authorize '/oauth/agentauthorize',:controller=>'oauth',:action=>'agentauthorize'
    map.revoke '/oauth/revoke', :controller => 'oauth', :action => 'revoke'
    map.request_token '/oauth/request_token',:controller=>'oauth',:action=>'request_token'
    map.access_token '/oauth/access_token',:controller=>'oauth',:action=>'access_token'
    map.test_request '/oauth/test_request',:controller=>'oauth',:action=>'test_request'
    map.test_session '/oauth/test_session', :controller => 'oauth', :action => 'test_session'

    map.resources :oauth_clients









    #custom album actions
    #map.connect "web_feeds/:action", :controller  => 'web_feeds', :action => /[a-z_]+/
    map.slideshow "albums/:id/slideshow", :controller  => 'albums', :action => 'slideshow'


    map.resources :user_sessions, :only => [:new, :create, :destroy]
    map.signin '/signin', :controller => 'user_sessions', :action => 'new'
    map.signout '/signout', :controller => 'user_sessions', :action => 'destroy'

    map.upload '/albums/:id/upload', :controller => 'albums', :action=>'upload'
    
    map.resources :password_resets, :only => [:new, :edit, :create, :update]

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "pages", :action => 'home'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
  
  map.contact '/contact', :controller => 'pages', :action => 'contact'
  map.about   '/about',   :controller => 'pages', :action => 'about'
  map.help    '/help',    :controller => 'pages', :action => 'help'
  map.signup '/signup',   :controller => 'users', :action => 'new'


#  map.connect '/google_sessions/new', :controller => 'google_sessions', :action=>'new'
#  map.connect '/google_sessions/create', :controller => 'google_sessions', :action=>'create'
#  map.connect '/google_sessions/destroy', :controller => 'google_sessions', :action=>'destroy'
#
#  map.connect '/google_contacts', :controller => 'google_contacts', :action=>'index'
#  map.reload_google_contacts '/google_contacts/reload', :controller => 'google_contacts', :action=>'reload'
#
#
#  map.connect '/facebook_sessions/new', :controller => 'facebook_sessions', :action=>'new'
#  map.connect '/facebook_sessions/destroy', :controller => 'facebook_sessions', :action=>'destroy'
#  map.connect '/facebook_sessions/verify', :controller => 'facebook_sessions', :action=>'verify'
#
#  map.connect '/facebook_posts/create', :controller => 'facebook_posts', :action=>'create'
#
#  map.resources :facebook_posts



  map.create_facebook_post '/facebook_posts/create', :controller => 'facebook_posts', :action=>'create'
  map.resources :facebook_posts

  map.create_google_session '/google_sessions/create', :controller => 'google_sessions', :action=>'create'
  map.destroy_google_session '/google_sessions/destroy', :controller => 'google_sessions', :action=>'destroy'
  map.resource :google_sessions
  map.resources :google_contacts



  #Flickr stuff
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

  #Kodak stuff
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

  #Facebook stuff
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

  #SmugMug stuff
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













end
