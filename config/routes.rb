#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

Server::Application.routes.draw do

  if Server::Application.config.bench_test_allowed
    scope :module => "bench_test" do
      get    '/bench_test'                   => 'bench_tests#showtests',             :as => :bench_tests
    end
    namespace :bench_test do resources :resque_no_ops end

    namespace :bench_test do resources :s3s end
  end

  root :to => 'pages#home'

  #users
  get    '/users'                   => 'users#index',             :as => :users
  get    '/users/new'               => 'users#new',               :as => :new_user
  get    '/users/validate_email'    => 'users#validate_email',    :as => :validate_email
  get    '/users/validate_username' => 'users#validate_username', :as => :validate_username
  post   '/users'                   => 'users#create',            :as => :create_user
  get    '/users/:id'              => 'users#show',              :as => :user
  get    '/users/:id/edit'          => 'users#edit',              :as => :edit_user
  put    '/users/:id'              => 'users#update',            :as => :update_user
  delete '/users/:id'              => 'users#destroy',           :as => :delete_user
  get    '/users/:id/account'    => 'users#account',    :as => :account
  get    '/users/:id/notifications'    => 'users#notifications',    :as => :notifications

  #identities  
  get    '/users/:id/identities'     => 'identities#index',       :as => :user_identities
  get    '/users/:id/identities/new' => 'identities#new',         :as => :new_user_identity
  post   '/users/:id/identities'     => 'identities#create',      :as => :create_user_identity
  get    '/identities/:id'          => 'identities#show',        :as => :identity
  get    '/identities/:id/edit'      => 'identities#edit',        :as => :edit_identity
  put    '/identities/:id'          => 'identities#update',      :as => :update_identity
  delete '/identities/:id'          => 'identities#destroy',     :as => :delete_identity

  #albums
  get    '/users/:user_id/albums'          => 'albums#index',               :as => :user_albums
  get    '/users/:user_id/albums/new'      => 'albums#new',                 :as => :new_user_album
  post   '/users/:user_id/albums'          => 'albums#create',              :as => :create_user_album
  get    '/albums/:id/name_album'          => 'albums#name_album',          :as => :name_album
  get    '/albums/:id/preview_album_email' => "albums#preview_album_email", :as => :preview_album_email
  get    '/albums/:id/privacy'             => 'albums#privacy',             :as => :privacy
  get    '/albums/:id/add_photos'          => 'albums#add_photos',          :as => :add_photos
  get    '/albums/:id/upload_stat'         => 'albums#upload_stat',         :as => :album_upload_stat
  get    '/albums/:id'                     => 'albums#show',                :as => :album
  get    '/albums/:id/edit'                => 'albums#edit',                :as => :edit_album
  get    '/albums/:id/close_batch'         => 'albums#close_batch',         :as => :close_batch
  put    '/albums/:id'                     => 'albums#update',              :as => :update_album
  delete '/albums/:id'                     => 'albums#destroy',             :as => :delete_album

  #shares
  get '/albums/:album_id/shares'          => 'shares#index',      :as => :album_shares
  get '/albums/:album_id/shares/new'      => 'shares#new',        :as => :new_album_share
  get '/albums/:album_id/shares/newpost'  => 'shares#newpost',    :as => :new_album_postshare
  get '/albums/:album_id/shares/newemail' => 'shares#newemail',   :as => :new_album_emailshare
  post '/albums/:album_id/shares'        => 'shares#create',     :as => :create_album_share
  get '/shares/:id'                      => 'shares#show',       :as => :share
  get '/shares/:id/edit'                  => 'shares#edit',       :as => :edit_share
  put '/shares/:id'                      => 'shares#update',     :as => :update_share
  delete '/shares/:id'                   => 'shares#destroy',    :as => :delete_share

  #photos
  get    '/albums/:album_id/photos'      => 'photos#index',                     :as => :album_photos
  post   '/albums/:album_id/photos'      => 'photos#create',                    :as => :create_album_photo
  get    '/albums/:album_id/slides_source.:format' => 'photos#slideshowbox_source',    :as => :slideshow_source
  get    '/photos/:id'                   => 'photos#show',                      :as => :photo
  get    '/photos/:id/edit'              => 'photos#edit',                      :as => :edit_photo
  put    '/photos/:id/edit'              => 'photos#update',                    :as => :update_photo
  delete '/photos/:id'                   => 'photos#destroy',                   :as => :destroy_photo
  put    '/photos/:id/upload_fast'       => 'photos#upload_fast',               :as => :upload_photo_fast
  get    '/agents/:agent_id/photos'      => 'photos#agentindex',                :as => :agent_photos
  post   '/albums/:album_id/photos/agent_create.:format' => 'photos#agent_create',      :as => :agent_create
  get    '/albums/:album_id/profile'      => 'photos#profile',                  :as => :profile
  put    '/photos/:id'                    => 'photos#update',                   :as => :update_photo

  #activities
  get '/albums/:album_id/activities' => 'activities#album_index', :as => :album_activities
  get '/users/:user_id/activities'   => 'activities#user_index',  :as => :user_activities

  #people
  get '/albums/:album_id/people' => 'people#album_index',         :as => :album_people
  get '/users/:user_id/people'   => 'people#user_index',          :as => :user_people

  #follows
  get    '/users/:user_id/follows'       => 'follows#index',      :as => :user_follows
  post   '/users/:user_id/follows/create' => 'follows#create',     :as => :create_user_follow
  get    '/users/:user_id/follows/new'   => 'follows#new',        :as => :new_user_follow
  delete '/follows/:id/unfollow'          => 'follows#unfollow',   :as => :unfollow
  put    '/follows/:id/block'             => 'follows#block',      :as => :block_follow
  put    '/follows/:id/unblock'           => 'follows#unblock',    :as => :unblock_follow

  #contributors
  get    '/albums/:album_id/contributors'          => 'contributors#index',      :as => :album_contributors
  get    '/albums/:album_id/contributors/new'      => 'contributors#new',        :as => :new_album_contributor
  post   '/albums/:album_id/contributors'         => 'contributors#create',     :as => :create_album_contributor
  get    '/contributors/:id'                      => 'contributors#show',       :as => :contributor
  get    '/contributors/:id/edit'                  => 'contributors#edit',       :as => :edit_contributor
  put    '/contributors/:id'                      => 'contributors#update',     :as => :update_contributor
  delete '/contributors/:id'                      => 'contributors#destroy',    :as => :delete_contributor 
    

  # oauth
  match '/users/:id/agents'     => 'agents#index',                 :as => :agents
  match '/agent/info'          => 'agents#info',                  :as => :agent_info
  match '/agents/check'      => 'agents#check',              :as => :check
  match '/oauth/authorize'      => 'oauth#authorize',              :as => :authorize
  match '/oauth/agentauthorize' => 'oauth#agentauthorize',         :as => :agentauthorize
  match '/oauth/revoke'         => 'oauth#revoke',                 :as => :revoke
  match '/oauth/request_token'  => 'oauth#request_token',          :as => :request_token
  match '/oauth/access_token'   => 'oauth#access_token',           :as => :access_token
  match '/oauth/test_request'   => 'oauth#test_request',           :as => :test_request
  match '/oauth/test_session'   => 'oauth#test_session',           :as => :test_session

  #sessions - login
  resources :user_sessions, :only => [:new, :create, :destroy]
  match '/signin'                    => 'user_sessions#new',            :as => :signin
  match '/signout'                   => 'user_sessions#destroy',        :as => :signout
  match '/activate/:activation_code' => 'activations#create',           :as => :activate
  match '/resend_activation'        => 'activations#resend_activation', :as => :resend_activation
  resources :password_resets, :only => [:new, :edit, :create, :update]
\

  #static pages
  get '/contact'  => 'pages#contact', :as => :contact
  get '/about'    => 'pages#about',   :as => :about
  get '/help'     => 'pages#help',    :as => :help
  get '/signup'   => 'users#new',     :as => :signup


  # all in this section are in the Connector namespace but don't include it in the path
  scope :module => "connector" do
    #flickr
    match '/flickr/sessions/new' => 'flickr_sessions#new', :as => :new_flickr_session
    match '/flickr/sessions/create' => 'flickr_sessions#create', :as => :create_flickr_session
    match '/flickr/sessions/destroy' => 'flickr_sessions#destroy', :as => :destroy_flickr_session
    match '/flickr/folders/:set_id/photos.:format' => 'flickr_photos#index', :as => :flickr_photos
    match '/flickr/folders/:set_id/photos/:photo_id/:action' => 'flickr_photos#action', :as => :flickr_photo_action
    match '/flickr/folders.:format' => 'flickr_folders#index', :as => :flickr_folders
    match '/flickr/folders/:set_id/:action.:format' => 'flickr_folders#index', :as => :flickr_folder_action

    #kodak
    match '/kodak/sessions/new' => 'kodak_sessions#new', :as => :new_kodak_session
    match '/kodak/sessions/create' => 'kodak_sessions#create', :as => :create_kodak_session
    match '/kodak/sessions/destroy' => 'kodak_sessions#destroy', :as => :destroy_kodak_session
    match '/kodak/folders/:kodak_album_id/photos.:format' => 'kodak_photos#index', :as => :kodak_photos
    match '/kodak/folders/:kodak_album_id/photos/:photo_id/:action' => 'kodak_photos#index', :as => :kodak_photo_action
    match '/kodak/folders.:format' => 'kodak_folders#index', :as => :kodak_folders
    match '/kodak/folders/:kodak_album_id/:action.:format' => 'kodak_folders#index', :as => :kodak_folder_action

    #facebook
    match '/facebook/sessions/new' => 'facebook_sessions#new', :as => :new_facebook_session
    match '/facebook/sessions/create' => 'facebook_sessions#create', :as => :create_facebook_session
    match '/facebook/sessions/destroy' => 'facebook_sessions#destroy', :as => :destroy_facebook_session
    match '/facebook/folders/:fb_album_id/photos.:format' => 'facebook_photos#index', :as => :facebook_photos
    match '/facebook/folders/:fb_album_id/photos/:photo_id/:action' => 'facebook_photos#index', :as => :facebook_photo_action
    match '/facebook/folders.:format' => 'facebook_folders#index', :as => :facebook_folders
    match '/facebook/folders/:fb_album_id/:action.:format' => 'facebook_folders#index', :as => :facebook_folder_action
    match '/facebook/posts.:format' => 'facebook_posts#index', :as => :facebook_posts
    match '/facebook/posts/create' => 'facebook_posts#create', :as => :create_facebook_post

    #smugmug
    match '/smugmug/sessions/new' => 'smugmug_sessions#new', :as => :new_smugmug_session
    match '/smugmug/sessions/create' => 'smugmug_sessions#create', :as => :create_smugmug_session
    match '/smugmug/sessions/destroy' => 'smugmug_sessions#destroy', :as => :destroy_smugmug_session
    match '/smugmug/folders/:sm_album_id/photos.:format' => 'smugmug_photos#index', :as => :smugmug_photos
    match '/smugmug/folders/:sm_album_id/photos/:photo_id/:action' => 'smugmug_photos#index', :as => :smugmug_photo_action
    match '/smugmug/folders.:format' => 'smugmug_folders#index', :as => :smugmug_folders
    match '/smugmug/folders/:sm_album_id/:action.:format' => 'smugmug_folders#index', :as => :smugmug_folder_action

    #shutterfly
    match '/shutterfly/sessions/new' => 'shutterfly_sessions#new', :as => :new_shutterfly_session
    match '/shutterfly/sessions/create' => 'shutterfly_sessions#create', :as => :create_shutterfly_session
    match '/shutterfly/sessions/destroy' => 'shutterfly_sessions#destroy', :as => :destroy_shutterfly_session
    match '/shutterfly/folders/:sf_album_id/photos.:format' => 'shutterfly_photos#index', :as => :shutterfly_photos
    match '/shutterfly/folders/:sf_album_id/photos/:photo_id/:action' => 'shutterfly_photos#index', :as => :shutterfly_photo_action
    match '/shutterfly/folders.:format' => 'shutterfly_folders#index', :as => :shutterfly_folders
    match '/shutterfly/folders/:sf_album_id/:action.:format' => 'shutterfly_folders#index', :as => :shutterfly_folder_action

    #photobucket
    match '/photobucket/sessions/new' => 'photobucket_sessions#new', :as => :new_photobucket_session
    match '/photobucket/sessions/create' => 'photobucket_sessions#create', :as => :create_photobucket_session
    match '/photobucket/sessions/destroy' => 'photobucket_sessions#destroy', :as => :destroy_photobucket_session
    match '/photobucket/folders' => 'photobucket_folders#index', :as => :photobucket_folders
    match '/photobucket/folders/:action' => 'photobucket_folders', :as => :photobucket

    #zangzing
    match '/zangzing/folders/:zz_album_id/photos.:format' => 'zangzing_photos#index', :as => :zangzing_photos
    match '/zangzing/folders/:zz_album_id/photos/:photo_id/:action' => 'zangzing_photos#index', :as => :zangzing_photo_action
    match '/zangzing/folders.:format' => 'zangzing_folders#index', :as => :zangzing_folders
    match '/zangzing/folders/:zz_album_id/:action.:format' => 'zangzing_folders#index', :as => :zangzing_folder_action

    #google
    match '/google/sessions/new' => 'google_sessions#new', :as => :new_google_session
    match '/google/sessions/create' => 'google_sessions#create', :as => :create_google_session
    match '/google/sessions/destroy' => 'google_sessions#destroy', :as => :destroy_google_session
    match '/google/contacts/:action' => 'google_contacts#index', :as => :google_contacts

    #picasa
    match '/picasa/sessions/new' => 'picasa_sessions#new', :as => :new_picasa_session
    match '/picasa/sessions/create' => 'picasa_sessions#create', :as => :create_picasa_session
    match '/picasa/sessions/destroy' => 'picasa_sessions#destroy', :as => :destroy_picasa_session
    match '/picasa/folders/:picasa_album_id/photos.:format' => 'picasa_photos#index', :as => :picasa_photos
    match '/picasa/folders/:picasa_album_id/photos/:photo_id/:action' => 'picasa_photos#index', :as => :picasa_photo_action
    match '/picasa/folders.:format' => 'picasa_folders#index', :as => :picasa_folders
    match '/picasa/folders/:picasa_album_id/:action.:format' => 'picasa_folders#index', :as => :picasa_folder_action

    #local contacts
    match '/local/contacts/:action' => 'local_contacts#index', :as => :local_contacts

    #yahoo
    match '/yahoo/sessions/new' => 'yahoo_sessions#new', :as => :new_yahoo_session
    match '/yahoo/sessions/create' => 'yahoo_sessions#create',:as => :create_yahoo_session
    match '/yahoo/sessions/destroy' => 'yahoo_sessions#destroy', :as => :destroy_yahoo_session
    match '/yahoo/contacts/:action' => 'yahoo_contacts#index', :as => :yahoo_contacts

    #Hotmail / MS Windows Live
    match '/mslive/sessions/new' => 'mslive_sessions#new', :as => :new_mslive_session
    match '/mslive/sessions/create' => 'mslive_sessions#delauth',:as => :create_mslive_session
    match '/mslive/sessions/destroy' => 'mslive_sessions#destroy', :as => :destroy_mslive_session
    match '/mslive/contacts/:action' => 'mslive_contacts#index', :as => :mslive_contacts

    #twitter
    match '/twitter/sessions/new' => 'twitter_sessions#new', :as => :new_twitter_session
    match '/twitter/sessions/create'=> 'twitter_sessions#create', :as => :create_twitter_session
    match '/twitter/sessions/destroy' => 'twitter_sessions#destroy', :as => :destroy_twitter_session
    match '/twitter/posts.:format' => 'twitter_posts#index', :as => :twitter_posts
    match '/twitter/posts/create' => 'twitter_posts#create', :as => :create_twitter_post

    #proxy
    match '/proxy' => 'proxy#proxy', :as => :proxy

  end # end of the namespace segment
  
  #sendgrid
  match '/sendgrid/import_fast' => 'sendgrid#import_fast', :as => :sendgrid_import_fast


  #logs
  unless Rails.env.production?
    match '/logs' => 'logs#index', :as => :logs
    match '/logs/:logname' => 'logs#retrieve', :as => :log_retrieve
  end
  
  #Resque: mount the resque server 
  mount Resque::Server.new, :at => "/resque"
  
end
