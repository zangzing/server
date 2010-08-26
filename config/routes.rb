#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
ActionController::Routing::Routes.draw do |map|
  #root
  map.root :controller => "pages", :action => 'home'

  #users
  map.with_options :controller => :users do |users|
    users.users        '/users',          :action=> 'index',  :conditions=>{ :method => :get }
    users.create_user  '/users',          :action=> 'create', :conditions=>{ :method => :post }
    users.new_user     '/users/new',      :action=> 'new',    :conditions=>{ :method => :get }
    users.edit_user    '/users/:id/edit', :action=> 'edit',   :conditions=>{ :method => :get }
    users.user         '/users/:id.',     :action=> 'show',   :conditions=>{ :method => :get }
    users.update_user  '/users/:id.',     :action=> 'update', :conditions=>{ :method => :put }
    users.delete_user  '/users/:id.',     :action=> 'destroy',:conditions=>{ :method => :delete }        
  end

  #albums
  map.with_options :controller => :albums do |albums|
    albums.user_albums        '/users/:user_id/albums.',     :action=>"index",  :conditions=>{ :method => :get }
    albums.create_user_album  '/users/:user_id/albums.',     :action=>"create", :conditions=>{ :method => :post }
    albums.edit_album         '/albums/:id/edit.',           :action=>"edit",   :conditions=>{ :method => :get }
    albums.new_user_album     '/users/:user_id/albums/new.', :action=>"wizard"
    albums.album              '/albums/:id.',                :action=>"show",   :conditions=>{ :method => :get }
    albums.update_album       '/albums/:id.',                :action=>"update", :conditions=>{ :method => :put }
    albums.delete_album       '/albums/:id.',                :action=>"destroy",:conditions=>{ :method => :delete }
    albums.upload             '/albums/:id/upload',          :action=>"upload", :conditions=>{ :method => :get }
    albums.album_wizard       '/albums/:id/wizard',          :action => 'wizard'
  end

 #shares
  map.with_options :controller => :shares do |shares|
    shares.album_shares        '/albums/:album_id/shares',         :action=> 'index',  :conditions=>{ :method => :get }
    shares.create_album_share  '/albums/:album_id/shares',         :action=> 'create', :conditions=>{ :method => :post }
    shares.new_album_share     '/albums/:album_id/shares/new',     :action=> 'new',    :conditions=>{ :method => :get }
    shares.new_album_postshare '/albums/:album_id/shares/newpost', :action=> 'newpost',:conditions=>{ :method => :get }
    shares.new_album_mailshare '/albums/:album_id/shares/newmail', :action=> 'newmail',:conditions=>{ :method => :get }
    shares.edit_share          '/shares/:id/edit',                 :action=> 'edit',   :conditions=>{ :method => :get }
    shares.share               '/shares/:id.',                     :action=> 'show',   :conditions=>{ :method => :get }
    shares.update_share        '/shares/:id.',                     :action=> 'update', :conditions=>{ :method => :put }
    shares.delete_share        '/shares/:id.',                     :action=> 'destroy',:conditions=>{ :method => :delete }
  end

  #photos
  map.with_options :controller => :photos do |photos|                                                                                                \
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
    photos.agent_create                '/albums/:album_id/photos/agent_create.:format',  :action=>'agent_create',    :conditions=>{ :method => :post }
  end

  #oauth
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

  #login
  map.resources :user_sessions, :only => [:new, :create, :destroy]
  map.signin '/signin', :controller => 'user_sessions', :action => 'new'
  map.signout '/signout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :password_resets, :only => [:new, :edit, :create, :update]

  #static pages
  map.contact '/contact', :controller => 'pages', :action => 'contact'
  map.about   '/about',   :controller => 'pages', :action => 'about'
  map.help    '/help',    :controller => 'pages', :action => 'help'
  map.signup '/signup',   :controller => 'users', :action => 'new'

  #Flickr
  map.with_options :namespace => 'connector', :controller => :flickr_sessions do |flickr|
    flickr.new_flickr_session     '/flickr/sessions/new', :action  => 'new'
    flickr.create_flickr_session  '/flickr/sessions/create', :action  => 'create'
    flickr.destroy_flickr_session '/flickr/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :namespace => 'connector', :controller => :flickr_photos do |flickr|
    flickr.flickr_photos '/flickr/folders/:set_id/photos.:format', :action  => 'index'
    #flickr.flickr_photo  '/flickr/folders/:set_id/photos/:photo_id.:size', :action  => 'show'
    flickr.flickr_photo_action  '/flickr/folders/:set_id/photos/:photo_id/:action'
  end

  map.with_options :namespace => 'connector',:controller => :flickr_folders do |flickr|
    flickr.flickr_folders '/flickr/folders.:format', :action  => 'index'
    flickr.flickr_folder_action '/flickr/folders/:set_id/:action.:format'
  end

  #Kodak
  map.with_options :namespace => 'connector',:controller => :kodak_sessions do |kodak|
    kodak.new_kodak_session     '/kodak/sessions/new', :action  => 'new'
    kodak.create_kodak_session  '/kodak/sessions/create', :action  => 'create'
    kodak.destroy_kodak_session '/kodak/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :namespace => 'connector', :controller => :kodak_photos do |kodak|
    kodak.kodak_photos '/kodak/folders/:kodak_album_id/photos.:format', :action  => 'index'
#    kodak.kodak_photo  '/kodak/folders/:kodak_album_id/photos/:photo_id.:size', :action  => 'show'
    kodak.kodak_photo_action '/kodak/folders/:kodak_album_id/photos/:photo_id/:action'
  end

  map.with_options :namespace => 'connector', :controller => :kodak_folders do |kodak|
    kodak.kodak_folders '/kodak/folders.:format', :action  => 'index'
    kodak.kodak_folder_action '/kodak/folders/:kodak_album_id/:action.:format'
  end

  #Facebook
  map.with_options :namespace => 'connector', :controller => :facebook_sessions do |fb|
    fb.new_facebook_session     '/facebook/sessions/new', :action  => 'new'
    fb.create_facebook_session  '/facebook/sessions/create', :action  => 'create'
    fb.destroy_facebook_session '/facebook/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :namespace => 'connector', :controller => :facebook_photos do |fb|
    fb.facebook_photos '/facebook/folders/:fb_album_id/photos.:format', :action  => 'index'
    #fb.facebook_photo  '/facebook/folders/:fb_album_id/photos/:photo_id.:size', :action  => 'show'
    fb.facebook_photo_action '/facebook/folders/:fb_album_id/photos/:photo_id/:action'
  end

  map.with_options :namespace => 'connector', :controller => :facebook_folders do |fb|
    fb.facebook_folders '/facebook/folders.:format', :action  => 'index'
    fb.facebook_folder_action '/facebook/folders/:fb_album_id/:action.:format'
  end

  map.with_options :namespace => 'connector', :controller => :facebook_posts do |fb|
    fb.facebook_posts           '/facebook/posts.:format',    :action  => 'index'
    fb.create_facebook_post  '/facebook/posts/create',     :action  => 'create'
  end

  #SmugMug
  map.with_options :namespace => 'connector', :controller => :smugmug_sessions do |fb|
    fb.new_smugmug_session     '/smugmug/sessions/new', :action  => 'new'
    fb.create_smugmug_session  '/smugmug/sessions/create', :action  => 'create'
    fb.destroy_smugmug_session '/smugmug/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :namespace => 'connector', :controller => :smugmug_photos do |fb|
    fb.smugmug_photos '/smugmug/folders/:sm_album_id/photos.:format', :action  => 'index'
#    fb.smugmug_photo  '/smugmug/folders/:sm_album_id/photos/:photo_id.:size', :action  => 'show'
    fb.smugmug_photo_action '/smugmug/folders/:sm_album_id/photos/:photo_id/:action'
  end

  map.with_options :namespace => 'connector', :controller => :smugmug_folders do |fb|
    fb.smugmug_folders '/smugmug/folders.:format', :action  => 'index'
    fb.smugmug_folder_action '/smugmug/folders/:sm_album_id/:action.:format'
  end

  #ShutterFly
  map.with_options :namespace => 'connector', :controller => :shutterfly_sessions do |sf|
    sf.new_shutterfly_session     '/shutterfly/sessions/new', :action  => 'new'
    sf.create_shutterfly_session  '/shutterfly/sessions/create', :action  => 'create'
    sf.destroy_shutterfly_session '/shutterfly/sessions/destroy', :action  => 'destroy'
  end

  map.with_options :namespace => 'connector', :controller => :shutterfly_photos do |sf|
    sf.shutterfly_photos '/shutterfly/folders/:sf_album_id/photos.:format', :action  => 'index'
    #sf.shutterfly_photo  '/shutterfly/folders/:sf_album_id/photos/:photo_id.:size', :action  => 'show'
    sf.shutterfly_photo_action '/shutterfly/folders/:sf_album_id/photos/:photo_id/:action'
  end

  map.with_options :namespace => 'connector', :controller => :shutterfly_folders do |sf|
    sf.shutterfly_folders '/shutterfly/folders.:format', :action  => 'index'
    sf.shutterfly_folder_action '/shutterfly/folders/:sf_album_id/:action.:format'
  end

  #Google
  map.with_options :namespace => 'connector', :controller => :google_sessions do |g|
    g.new_google_session     '/google/sessions/new', :action  => 'new'
    g.create_google_session  '/google/sessions/create', :action  => 'create'
    g.destroy_google_session '/google/sessions/destroy', :action  => 'destroy'
  end
  map.google_contacts '/google/contacts/:action', :namespace => 'connector',  :controller => 'google_contacts'

  #LocalContacts importer
  map.local_contacts '/local/contacts/:action', :namespace => 'connector', :controller => 'local_contacts'

  #Yahoo
  map.with_options :namespace => 'connector', :controller => :yahoo_sessions do |y|
    y.new_yahoo_session     '/yahoo/sessions/new', :action  => 'new'
    y.create_yahoo_session  '/yahoo/sessions/create', :action  => 'create'
    y.destroy_yahoo_session '/yahoo/sessions/destroy', :action  => 'destroy'
  end
  map.yahoo_contacts '/yahoo/contacts/:action', :namespace => 'connector', :controller => 'yahoo_contacts'

  #Twitter
  map.with_options :namespace => 'connector', :controller => :twitter_sessions do |tw|
    tw.new_twitter_session     '/twitter/sessions/new', :action  => 'new'
    tw.create_twitter_session  '/twitter/sessions/create', :action  => 'create'
    tw.destroy_twitter_session '/twitter/sessions/destroy', :action  => 'destroy'
  end
  map.with_options :namespace => 'connector', :controller => :twitter_posts do |tw|
    tw.twitter_posts           '/twitter/posts.:format',    :action  => 'index'
    tw.create_twitter_post     '/twitter/posts/create',     :action  => 'create'
  end

  #proxy
  map.with_options :namespace => 'connector', :controller => :proxy do |proxy|
    proxy.proxy            '/proxy',    :action  => 'proxy'
  end



end
