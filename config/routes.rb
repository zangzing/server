
#

#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

Server::Application.routes.draw do
  root :to => 'pages#home'
  get    '/beta'               => 'pages#home'
  get    '/service'            => 'pages#home',          :as => :service
  get    '/signin'             => 'user_sessions#new',   :as => :signin
  get    '/join'               => 'users#join',          :as => :join
  get    '/unsubscribe/:id'    => 'subscriptions#unsubscribe', :as => :unsubscribe

  get    '/invitation'  => 'invitations#show', :as => :invitation  , :requirements => {:protocol => 'https'}
  get    '/invite_friends'  => 'invitations#invite_friends', :as => :invite_friends

  # the whole site has /service in front of it except for users
  scope '/service' do

    if Server::Application.config.bench_test_allowed
      scope :module => "bench_test" do
        get    '/bench_test'                   => 'bench_tests#showtests',             :as => :bench_tests
      end
      namespace :bench_test do resources :resque_no_ops end
      namespace :bench_test do resources :s3s end
      namespace :bench_test do resources :photo_gens end
    end

    get    '/health_check'            => 'pages#health_check',      :as => :health_check
    
    #invitations
    get    '/invitations/send_to_facebook' => 'invitations#send_to_facebook'  , :as=>'send_invitations_to_facebook'
    get    '/invitations/send_to_twitter' => 'invitations#send_to_twitter'   , :as=>'send_invitations_to_twitter'
    post   '/invitations/send_to_email' => 'invitations#send_to_email'     , :as=>'send_invitations_to_email'
    post   '/invitations/send_reminder' => 'invitations#send_reminder'     , :as=>'send_invitation_reminder'

    #users
    get    '/users/new'                 => 'users#new',               :as => :new_user
    get    '/users/validate_email'      => 'users#validate_email',    :as => :validate_email
    get    '/users/validate_username'   => 'users#validate_username', :as => :validate_username
    post   '/users'                     => 'users#create',            :as => :create_user, :requirements => {:protocol => 'https'}
    put    '/users/:id'                 => 'users#update',            :as => :update_user
    delete '/users/:id'                 => 'users#destroy',           :as => :delete_user
    match  '/users/:id/update_password' => 'users#update_password',   :as => :update_user_password, :requirements => {:protocol => 'https'}

    #email_subscirptions
    match '/subscriptions/mcsync'      => 'subscriptions#mcsync'
    get   '/subscriptions/:id'         => 'subscriptions#unsubscribe'   #see unsubscribe above
    put   '/subscriptions/:id'         => 'subscriptions#update',       :as => :update_subscriptions

    #identities
    get    '/users/:id/identities'     => 'identities#index',       :as => :user_identities
    get    '/users/:id/identities/new' => 'identities#new',         :as => :new_user_identity
    post   '/users/:id/identities'     => 'identities#create',      :as => :create_user_identity
    get    '/identities/:id'           => 'identities#show',        :as => :identity
    get    '/identities/:id/edit'      => 'identities#edit',        :as => :edit_identity
    put    '/identities/:id'           => 'identities#update',      :as => :update_identity
    delete '/identities/:id'           => 'identities#destroy',     :as => :delete_identity

    #albums
    get    '/users/:user_id/my_albums_json'                 => 'albums#my_albums_json',                 :as => :my_albums_json
    get    '/users/:user_id/my_albums_public_json'          => 'albums#my_albums_public_json',          :as => :my_albums_public_json
    get    '/users/:user_id/liked_albums_json'              => 'albums#liked_albums_json',              :as => :liked_albums_json
    get    '/users/:user_id/liked_albums_public_json'       => 'albums#liked_albums_public_json',       :as => :liked_albums_public_json
    get    '/users/:user_id/liked_users_public_albums_json' => 'albums#liked_users_public_albums_json', :as => :liked_users_public_albums_json
    get    '/users/:user_id/invited_albums_json'            => 'albums#invited_albums_json',            :as => :invited_albums_json


    get    '/users/:user_id/albums'                => 'albums#index'             #, :as => :user_albums  user albums defined below
    put    '/users/:user_id/invalidate_cache'      => 'albums#invalidate_cache',    :as => :invalidate_user_album_cache
    get    '/users/:user_id/albums/new'            => 'albums#new',                       :as => :new_user_album
    post   '/users/:user_id/albums'                => 'albums#create',                    :as => :create_user_album
    get    '/albums/:album_id/name_album'          => 'albums#name_album',          :as => :name_album
    get    '/albums/:album_id/preview_album_email' => "albums#preview_album_email", :as => :preview_album_email
    get    '/albums/:album_id/privacy'             => 'albums#privacy',             :as => :privacy
    get    '/albums/:album_id/download'            => 'albums#download',            :as => :download_album
    get    '/albums/:album_id/download_direct'     => 'albums#download_direct',     :as => :download_direct_album
#   get    '/albums/:album_id'                     => 'albums#show',                :as => :album
#   get    '/albums/:album_id/edit'                => 'albums#edit',                :as => :edit_album
    get    '/albums/:album_id/close_batch'         => 'albums#close_batch',         :as => :close_batch
    put    '/albums/:album_id'                     => 'albums#update',              :as => :update_album
    delete '/albums/:album_id'                     => 'albums#destroy',             :as => :delete_album
    post   'albums/:album_id/request_access'       => 'albums#request_access',      :as => :request_album_access
    get    '/albums/:album_id/add_photos'          => 'albums#add_photos',          :as => :album_add_photos
    get    '/albums/:album_id/wizard/:step'        => 'albums#wizard',              :as => :album_wizard

    #shares
    get    '/albums/:album_id/shares'             => 'shares#index',            :as => :album_shares
    get    '/shares/new'                          => 'shares#new'   # ,         :as => :new_album_share
    get    '/shares/newpost'                      => 'shares#newpost' #,        :as => :new_album_postshare
    get    '/shares/newemail'                     => 'shares#newemail' #,       :as => :new_album_emailshare
    post   '/albums/:album_id/shares'             => 'shares#create',           :as => :create_album_share
    post   '/photos/:photo_id/shares'             => 'shares#create',           :as => :create_photo_share
    get    '/shares/:id'                          => 'shares#show',             :as => :share
    get    '/shares/:id/edit'                     => 'shares#edit',             :as => :edit_share
    put    '/shares/:id'                          => 'shares#update',           :as => :update_share
    delete '/shares/:id'                          => 'shares#destroy',          :as => :delete_share
    get    '/albums/:album_id/new_twitter_share'  => 'shares#new_twitter_share'
    get    '/albums/:album_id/new_facebook_share' => 'shares#new_facebook_share'
    get    '/albums/:album_id/new_mailto_share'   => 'shares#new_mailto_share'
    get    '/photos/:photo_id/new_twitter_share'  => 'shares#new_twitter_share'
    get    '/photos/:photo_id/new_facebook_share' => 'shares#new_facebook_share'
    get  '/photos/:photo_id/new_mailto_share'     => 'shares#new_mailto_share'

    #photos
    get    '/albums/:album_id/photos_json'  => 'photos#photos_json',                :as => :album_photos_json
    put    '/albums/:album_id/photos_json_invalidate'  => 'photos#photos_json_invalidate',  :as => :album_invalidate_photos_json
    get    '/albums/:album_id/photos'       => 'photos#index',                      :as => :album
    get    '/albums/:album_id/movie'        => 'photos#movie',                      :as => :album_movie
    delete '/photos/:id'                    => 'photos#destroy',                    :as => :destroy_photo
    put    '/photos/:id/upload_fast'        => 'photos#upload_fast',                :as => :upload_photo_fast
    put   '/albums/:album_id/upload_fast'   => 'photos#simple_upload_fast',    :as => :simple_upload_photo_fast
    get    '/agents/:agent_id/photos'       => 'photos#agent_index',                :as => :agent_photos
    post   '/albums/:album_id/photos/agent_create.:format' => 'photos#agent_create',:as => :agent_create
    get    '/photos/:id/download'           => 'photos#download',                   :as => :download_photo
    put    '/photos/:id'                    => 'photos#update',                     :as => :update_photo
    put    '/photos/:id/position'           => 'photos#position',                   :as => :photo_position
    put    '/photos/:id/async_edit'         => 'photos#async_edit',                 :as => :photo_async_edit
    put    '/photos/:id/async_rotate_left'  => 'photos#async_rotate_left',          :as => :photo_async_rotate_left
    put    '/photos/:id/async_rotate_right' => 'photos#async_rotate_right',         :as => :photo_async_rotate_right


    #comments
    get    '/photos/:photo_id/comments'                      => 'comments#index',                      :as => :photo_comments
    get    '/albums/:album_id/photos/comments/metadata'      => 'comments#metadata_for_album_photos',  :as => :album_photos_comments_metadata
    match  '/comments/metadata_for_subjects'                 => 'comments#metadata_for_subjects'
    post   '/photos/:photo_id/comments'                      => 'comments#create',                     :as => :create_photo_comment
    delete '/comments/:comment_id'                           => 'comments#destroy',                    :as => :destroy_comment
    get    '/photos/:photo_id/comments/finish_create'  => 'comments#finish_create',              :as => :finish_create_photo_comment

    #activities
    get '/albums/:album_id/activities' => 'activities#album_index', :as => :album_activities
    get '/users/:user_id/activities'   => 'activities#user_index'

    #people
    get '/albums/:album_id/people' => 'people#album_index',         :as => :album_people
    get '/users/:user_id/people'   => 'people#user_index'

    #contributors
#    get    '/albums/:album_id/contributors/new'  => 'contributors#new',        :as => :new_album_contributor
#    get    '/albums/:album_id/contributors'      => 'contributors#index',      :as => :album_contributors
#    post   '/albums/:album_id/contributors'      => 'contributors#create',     :as => :create_album_contributor
#    delete '/albums/:album_id/contributors'      => 'contributors#destroy',    :as => :delete_contributor

    #like
    match  '/likes'                              => 'likes#index',             :as => :likes
    post   '/likes/:subject_id'                  => 'likes#create',            :as => :like
    get    '/users/:user_id/like'                => 'likes#like',            :as => :like_user
    get    '/albums/:album_id/like'              => 'likes#like',            :as => :like_album
    get    '/photos/:photo_id/like'              => 'likes#like',            :as => :like_photo
    delete '/likes/:subject_id'                  => 'likes#destroy',           :as => :delete_like
    #post   '/likes/:subject_id/post'             => 'likes#post',              :as => :post_like

    #contacts
    get    '/users/:user_id/contacts'            => 'contacts#index',          :as => :user_contacts


    # oauth
#    match '/users/:id/agents'     => 'agents#index',                 :as => :agents
#    match '/agent/info'           => 'agents#info',                  :as => :agent_info
#    match '/agents/check'         => 'agents#check',                 :as => :check
    match '/oauth/authorize'      => 'oauth#authorize',              :as => :authorize
    match '/oauth/agentauthorize' => 'oauth#agentauthorize',         :as => :agentauthorize
    match '/oauth/revoke'         => 'oauth#revoke',                 :as => :revoke
    match '/oauth/request_token'  => 'oauth#request_token',          :as => :request_token
    match '/oauth/access_token'   => 'oauth#access_token',           :as => :access_token
    match '/oauth/test_request'   => 'oauth#test_request',           :as => :test_request
    match '/oauth/test_session'   => 'oauth#test_session',           :as => :test_session

    #sessions - login
    get '/user_sessions/new'           => 'user_sessions#new',             :as => :new_user_session
    post '/user_sessions/create'       => 'user_sessions#create',          :as => :create_user_session, :requirements => {:protocol => 'https'}
    
    match '/signin'                    => 'user_sessions#new'
    match '/inactive'                  => 'user_sessions#inactive',       :as => :inactive
    match '/signout'                   => 'user_sessions#destroy',        :as => :signout



    #password resets
    match '/password_resets/new'         => 'password_resets#new',        :as => :new_password_reset
    get '/password_resets/:id/edit'    => 'password_resets#edit',        :as => :edit_password_reset,     :requirements => {:protocol => 'https'}
    post '/password_resets/create'      => 'password_resets#create',     :as => :create_password_reset,   :requirements => {:protocol => 'https'}
    put '/password_resets/:id/update'  => 'password_resets#update',     :as => :update_password_reset,   :requirements => {:protocol => 'https'}


#    resources :password_resets, :only => [:new, :edit, :create, :update]

    #Asynch responses
    match '/async_responses/:response_id' => 'async_responses#show', :as => :async_response


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
      match '/flickr/folders/import_all.:format' => 'flickr_folders#import_all', :as => :flickr_import_all

      #kodak
      match '/kodak/sessions/new' => 'kodak_sessions#new', :as => :new_kodak_session
      match '/kodak/sessions/create' => 'kodak_sessions#create', :as => :create_kodak_session
      match '/kodak/sessions/close' => 'kodak_sessions#close', :as => :close_kodak_session
      match '/kodak/sessions/destroy' => 'kodak_sessions#destroy', :as => :destroy_kodak_session
      match '/kodak/folders/:kodak_album_id/photos.:format' => 'kodak_photos#index', :as => :kodak_photos
      match '/kodak/folders/:kodak_album_id/photos/:photo_id/:action' => 'kodak_photos#index', :as => :kodak_photo_action
      match '/kodak/folders.:format' => 'kodak_folders#index', :as => :kodak_folders
      match '/kodak/folders/:kodak_album_id/:action.:format' => 'kodak_folders#index', :as => :kodak_folder_action
      match '/kodak/folders/import_all.:format' => 'kodak_folders#import_all', :as => :kodak_import_all

      #facebook
      match '/facebook/sessions/new' => 'facebook_sessions#new', :as => :new_facebook_session
      match '/facebook/sessions/create' => 'facebook_sessions#create', :as => :create_facebook_session
      match '/facebook/sessions/destroy' => 'facebook_sessions#destroy', :as => :destroy_facebook_session
      match '/facebook/folders/:fb_album_id/photos.:format' => 'facebook_photos#index', :as => :facebook_photos
      match '/facebook/folders/:fb_album_id/photos/:photo_id/:action' => 'facebook_photos#index', :as => :facebook_photo_action
      match '/facebook/folders.:format' => 'facebook_folders#index', :as => :facebook_folders
      match '/facebook/folders/:fb_album_id/:action.:format' => 'facebook_folders#index', :as => :facebook_folder_action
#      match '/facebook/posts.:format' => 'facebook_posts#index', :as => :facebook_posts
#      match '/facebook/posts/create' => 'facebook_posts#create', :as => :create_facebook_post
      match '/facebook/folders/import_all.:format' => 'facebook_folders#import_all', :as => :facebook_import_all

      #smugmug
      match '/smugmug/sessions/new' => 'smugmug_sessions#new', :as => :new_smugmug_session
      match '/smugmug/sessions/create' => 'smugmug_sessions#create', :as => :create_smugmug_session
      match '/smugmug/sessions/destroy' => 'smugmug_sessions#destroy', :as => :destroy_smugmug_session
      match '/smugmug/folders/:sm_album_id/photos.:format' => 'smugmug_photos#index', :as => :smugmug_photos
      match '/smugmug/folders/:sm_album_id/photos/:photo_id/:action' => 'smugmug_photos#index', :as => :smugmug_photo_action
      match '/smugmug/folders.:format' => 'smugmug_folders#index', :as => :smugmug_folders
      match '/smugmug/folders/:sm_album_id/:action.:format' => 'smugmug_folders#index', :as => :smugmug_folder_action
      match '/smugmug/folders/import_all.:format' => 'smugmug_folders#import_all', :as => :smugmug_import_all

      #shutterfly
      match '/shutterfly/sessions/new' => 'shutterfly_sessions#new', :as => :new_shutterfly_session
      match '/shutterfly/sessions/create' => 'shutterfly_sessions#create', :as => :create_shutterfly_session
      match '/shutterfly/sessions/destroy' => 'shutterfly_sessions#destroy', :as => :destroy_shutterfly_session
      match '/shutterfly/folders/:sf_album_id/photos.:format' => 'shutterfly_photos#index', :as => :shutterfly_photos
      match '/shutterfly/folders/:sf_album_id/photos/:photo_id/:action' => 'shutterfly_photos#index', :as => :shutterfly_photo_action
      match '/shutterfly/folders.:format' => 'shutterfly_folders#index', :as => :shutterfly_folders
      match '/shutterfly/folders/:sf_album_id/:action.:format' => 'shutterfly_folders#index', :as => :shutterfly_folder_action
      match '/shutterfly/folders/import_all.:format' => 'shutterfly_folders#import_all', :as => :shutterfly_import_all

      #instagram
      match '/instagram/sessions/new' => 'instagram_sessions#new', :as => :new_instagram_session
      match '/instagram/sessions/create' => 'instagram_sessions#create', :as => :create_instagram_session
      match '/instagram/sessions/destroy' => 'instagram_sessions#destroy', :as => :destroy_instagram_session
      match '/instagram/folders/:target/photos.:format' => 'instagram_photos#index', :as => :instagram_photos
      match '/instagram/folders/:target/photos/:photo_id/:action' => 'instagram_photos#index', :as => :instagram_photo_action
      match '/instagram/folders.:format' => 'instagram_folders#index', :as => :instagram_folders
      match '/instagram/folders/:target/:action.:format' => 'instagram_folders#index', :as => :instagram_folder_action
      match '/instagram/folders/import_all.:format' => 'instagram_folders#import_all', :as => :instagram_import_all

      #photobucket
      match '/photobucket/sessions/new' => 'photobucket_sessions#new', :as => :new_photobucket_session
      match '/photobucket/sessions/create' => 'photobucket_sessions#create', :as => :create_photobucket_session
      match '/photobucket/sessions/destroy' => 'photobucket_sessions#destroy', :as => :destroy_photobucket_session
      match '/photobucket/folders' => 'photobucket_folders#index', :as => :photobucket_folders
      match '/photobucket/folders/:action' => 'photobucket_folders', :as => :photobucket
      match '/photobucket/folders/import_all.:format' => 'photobucket_folders#import_all', :as => :photobucket_import_all

      #dropbox
      match '/dropbox/sessions/new' => 'dropbox_sessions#new', :as => :new_dropbox_session
      match '/dropbox/sessions/create' => 'dropbox_sessions#create', :as => :create_dropbox_session
      match '/dropbox/sessions/destroy' => 'dropbox_sessions#destroy', :as => :destroy_dropbox_session
      match '/dropbox/folders' => 'dropbox_folders#index', :as => :dropbox_folders
      match '/dropbox/folders/:action' => 'dropbox_folders', :as => :dropbox
      match '/dropbox/urls/:root/*path' => 'dropbox_urls#serve_image', :as => :dropbox_image, :defaults => {:dont_store_location => true}

      #mobile.me
      match '/mobileme/sessions/new' => 'mobileme_sessions#new', :as => :new_mobileme_session
      match '/mobileme/sessions/create' => 'mobileme_sessions#create', :as => :create_mobileme_session
      match '/mobileme/sessions/close' => 'mobileme_sessions#close', :as => :close_mobileme_session
      match '/mobileme/sessions/destroy' => 'mobileme_sessions#destroy', :as => :destroy_mobileme_session
      match '/mobileme/folders.:format' => 'mobileme_folders#index', :as => :mobileme_folders
      match '/mobileme/folders/:mm_album_id/:action.:format' => 'mobileme_folders#album_index', :as => :mobileme_photos
      match '/mobileme/folders/import_all.:format' => 'mobileme_folders#import_all', :as => :mobileme_import_all

      #zangzing
      match '/zangzing/folders/:zz_album_id/photos.:format' => 'zangzing_photos#index', :as => :zangzing_photos
      match '/zangzing/folders/:zz_album_id/photos/:photo_id/:action' => 'zangzing_photos#index', :as => :zangzing_photo_action
      match '/zangzing/folders.:format' => 'zangzing_folders#index', :as => :zangzing_folders
      match '/zangzing/folders/:zz_album_id/:action.:format' => 'zangzing_folders#index', :as => :zangzing_folder_action

      #google
      match '/google/sessions/new' => 'google_sessions#new', :as => :new_google_session
      match '/google/sessions/create' => 'google_sessions#create', :as => :create_google_session
      match '/google/sessions/destroy' => 'google_sessions#destroy', :as => :destroy_google_session
      match '/google/contacts/import' => 'google_contacts#import'
      
      #picasa
      #google session controller used
      match '/google/folders/:picasa_album_id/photos.:format' => 'picasa_photos#index', :as => :picasa_photos
      match '/google/folders/:picasa_album_id/photos/:photo_id/:action' => 'picasa_photos#index', :as => :picasa_photo_action
      match '/google/folders.:format' => 'picasa_folders#index', :as => :picasa_folders
      match '/google/folders/:picasa_album_id/:action.:format' => 'picasa_folders#index', :as => :picasa_folder_action
      match '/google/folders/import_all.:format' => 'picasa_folders#import_all', :as => :picasa_import_all

      #local contacts
      match '/local/contacts/import' => 'local_contacts#import', :as => :local_contacts

      #yahoo
      match '/yahoo/sessions/new' => 'yahoo_sessions#new', :as => :new_yahoo_session
      match '/yahoo/sessions/create' => 'yahoo_sessions#create',:as => :create_yahoo_session
      match '/yahoo/sessions/destroy' => 'yahoo_sessions#destroy', :as => :destroy_yahoo_session
      match '/yahoo/contacts/import' => 'yahoo_contacts#import'



      #Hotmail / MS Windows Live
      match '/mslive/sessions/new' => 'mslive_sessions#new', :as => :new_mslive_session
      match '/mslive/sessions/create' => 'mslive_sessions#delauth',:as => :create_mslive_session
      match '/mslive/sessions/destroy' => 'mslive_sessions#destroy', :as => :destroy_mslive_session
      match '/mslive/contacts/import' => 'mslive_contacts#import', :as => :mslive_contacts

      #twitter
      match '/twitter/sessions/new' => 'twitter_sessions#new', :as => :new_twitter_session
      match '/twitter/sessions/create'=> 'twitter_sessions#create', :as => :create_twitter_session
      match '/twitter/sessions/destroy' => 'twitter_sessions#destroy', :as => :destroy_twitter_session
#      match '/twitter/posts.:format' => 'twitter_posts#index', :as => :twitter_posts
#      match '/twitter/posts/create' => 'twitter_posts#create', :as => :create_twitter_post

      #proxy
      match '/proxy' => 'proxy#proxy', :as => :proxy
    end # end of the namespace segment

    #sendgrid
    match  '/sendgrid/import_fast'   => 'sendgrid#import_fast', :as => :sendgrid_import_fast
    post   '/sendgrid/unsubscribe'   => 'sendgrid#un_subscribe',:as => :sendgrid_unsubscribe
    post   '/sendgrid/events'        => 'sendgrid#events',      :as => :sendgrid_events



    # ====================================================================================================
    # =============================================== ADMIN ==============================================
    # ====================================================================================================
    scope  '/moderator', :module => "moderator" do
        get   '/'                               => 'base#index',            :as => :moderator
        get   'upload_batches'                  => 'upload_batches#index',  :as => :moderator_upload_batches
        get   'upload_batches/:date'            => 'upload_batches#show',   :as => :moderator_upload_batch
        get   'upload_batches/:id/report_abuse' => 'upload_batches#report', :as => :moderator_upload_batch_report
    end

    scope  '/admin', :module => "admin" do
        get   '/'                               => 'admin_screens#index',         :as => :admin
        get   'logs'                            => 'logs#index',                  :as => :logs
        get   'logs/:logname'                   => 'logs#retrieve',               :as => :log_retrieve
        resources :email_templates
        put   'email_templates/:id/reload'       => 'email_templates#reload',     :as => :reload_email_template
        get   'email_templates/:id/test'         => 'email_templates#test',       :as => :test_email_template
        get   'emails'                           => 'emails#index',               :as => :emails
        put   'emails/:id'                       => 'emails#update',              :as => :email
        get   'settings'                         => 'system_settings#show',       :as => :system_settings
        put   'settings'                         => 'system_settings#update'
        get   'homepage'                         => 'homepage#show',              :as => :homepage
        put   'homepage'                         => 'homepage#update'
  
        get   'guests'                           => 'guests#index',               :as => :guests
        post  'guests(.:format)'                 => 'guests#create'
        get   'guests/:id'                       => 'guests#show',                :as => :guest
        put   'guests/:id/activate'              => 'guests#activate',            :as => :activate_guest
        get   'users'                            => 'users#index',                :as => :users
        get   'users/unimpersonate'              => 'users#unimpersonate',        :as => :admin_unimpersonate
        get   'users/:id'                        => 'users#show',                 :as => :admin_user_show
        put   'users/:id/activate'               => 'users#activate',             :as => :admin_activate_user
        put   'users/:id/reset_password'         => 'users#reset_password',       :as => :admin_reset_password
        put   'users/:id/impersonate'            => 'users#impersonate',          :as => :admin_impersonate

        get   'heap'                            => 'heap#index'
        get   'heap_track'                      => 'heap#track'
        get   'em_heap'                         => 'heap#em_index'
        get   'em_heap_track'                   => 'heap#em_track'
    end

    #Resque: mount the resque server
    mount Resque::Server.new,   :at => '/admin/resque'
    
    scope :module =>:store do
      get 'creditcards/new' => 'creditcards#new'
    end
  end


  # STORE ROUTES
  require File.expand_path(File.dirname(__FILE__) + '/../spree_zangzing/config/routes')



  #jammit routes -- needs to be before catch all user routes below (copied from jammit/rails/routes.rb
  match "/#{Jammit.package_path}/:package.:extension",
    :to => 'jammit#package', :as => :jammit, :constraints => {
      # A hack to allow extension to include "."
      :extension => /.+/
  }

  # ====================================================================================================
  # ============================================= ZZ_API  ==============================================
  # ====================================================================================================
  # limit the verb to post and get to keep things simple for clients that don't support other types
  #
  scope  '/zz_api', :defaults => { :format => 'json' } do
    post  '/login'                 => 'user_sessions#zz_api_create',    :as => :zz_api_login
    post  '/logout'                => 'user_sessions#zz_api_destroy',   :as => :zz_api_logout

    #albums
    get    '/users/:user_id/albums'                    => 'albums#zz_api_albums',                    :as => :zz_api_albums
    get    '/users/:user_id/my_albums'                 => 'albums#zz_api_my_albums',                 :as => :zz_api_my_albums
    get    '/users/:user_id/my_albums_public'          => 'albums#zz_api_my_albums_public',          :as => :zz_api_my_albums_public
    get    '/users/:user_id/liked_albums'              => 'albums#zz_api_liked_albums',              :as => :zz_api_liked_albums
    get    '/users/:user_id/liked_albums_public'       => 'albums#zz_api_liked_albums_public',       :as => :zz_api_liked_albums_public
    get    '/users/:user_id/liked_users_public_albums' => 'albums#zz_api_liked_users_public_albums', :as => :zz_api_liked_users_public_albums
    get    '/users/:user_id/invited_albums'            => 'albums#zz_api_invited_albums',            :as => :zz_api_invited_albums
    post   '/users/albums/create'                      => 'albums#zz_api_create',                    :as => :zz_api_create_album
    post   '/albums/:album_id/update'                  => 'albums#zz_api_update',                    :as => :zz_api_update_album
    get    '/albums/:album_id'                         => 'albums#zz_api_album_info',                :as => :zz_api_album_info
    post   '/albums/:album_id/delete'                  => 'albums#zz_api_destroy',                   :as => :zz_api_destroy_album
    post   '/albums/:album_id/close_batch'             => 'albums#zz_api_close_batch',               :as => :zz_api_close_batch
    get    '/albums/:album_id/sharing_edit'            => 'albums#zz_api_sharing_edit',              :as => :zz_api_sharing_edit_album
    post   '/albums/:album_id/add_sharing_members'     => 'albums#zz_api_add_sharing_members',       :as => :zz_api_add_sharing_members_album
    post   '/albums/:album_id/update_sharing_member'   => 'albums#zz_api_update_sharing_member',     :as => :zz_api_update_sharing_member_album
    post   '/albums/:album_id/delete_sharing_member'   => 'albums#zz_api_delete_sharing_member',     :as => :zz_api_delete_sharing_member_album
    get    '/albums/:album_id/sharing_members'         => 'albums#zz_api_sharing_members',           :as => :zz_api_sharing_members_album

    #photos
    get    '/albums/:album_id/photos'                  => 'photos#zz_api_photos',                    :as => :zz_api_photos
    post   '/albums/:album_id/photos/create_photos'    => 'photos#zz_api_create_photos',             :as => :zz_api_create_photos
    get    '/photos/:agent_id/pending_uploads'         => 'photos#zz_api_pending_uploads',           :as => :zz_api_pending_uploads
    # internal, used by nginx, external upload is /zz_api/photos/:photo_id/upload
    # needs to remain a put
    put    '/photos/:id/upload_fast'                   => 'photos#upload_fast',                      :as => :zz_api_upload_photo_fast

    #users
    get    '/users/:user_id/info'                      => 'users#zz_api_user_info',                  :as => :zz_api_user_info
    post   '/users/find_or_create'                     => 'users#zz_api_find_or_create',             :as => :zz_api_find_or_create_user

    #groups
    post   '/groups/create'                            => 'groups#zz_api_create',                    :as => :zz_api_create_group
    post   '/groups/:group_id/delete'                  => 'groups#zz_api_destroy',                   :as => :zz_api_destroy_group
    post   '/groups/:group_id/update'                  => 'groups#zz_api_update',                    :as => :zz_api_update_group
    get    '/groups/:group_id'                         => 'groups#zz_api_info',                      :as => :zz_api_info_group
    get    '/users/groups/all'                         => 'groups#zz_api_users_groups',              :as => :zz_api_users_groups
    get    '/groups/:group_id/members'                 => 'groups#zz_api_members',                   :as => :zz_api_members_group
    post   '/groups/:group_id/add_members'             => 'groups#zz_api_add_members',               :as => :zz_api_add_members_group
    post   '/groups/:group_id/remove_members'          => 'groups#zz_api_remove_members',            :as => :zz_api_remove_members_group


    #identities
    get     '/identities' => 'identities#zz_api_identities'
    get     '/identities/:service_name' => 'identities#zz_api_identity'

  end


  # Root level user
  get    '/:username/settings'                 => 'users#edit',              :as => :edit_user
  get    '/:username/change_password'          => 'users#edit_password',     :as => :edit_user_password


  get    '/:user_id'                           => 'albums#index',           :as => :user
  get    '/:user_id/activities'                => 'activities#user_index',  :as => :user_activities
  get    '/:user_id/people'                    => 'people#user_index',      :as => :user_people
  get    '/:user_id/:album_id'                 => 'photos#index'
  get    '/:user_id/:album_id/photos'          => 'photos#index'
  get    '/:user_id/:album_id/people'          => 'people#album_index'
  get    '/:user_id/:album_id/activities'      => 'activities#album_index'
  get    '/:user_id/:album_id/movie'           => 'photos#movie'
  get    '/:user_id/:album_id/slideshow.js'    => 'photos#embedded_slideshow_js'
  get    '/:user_id/:album_id/photos/:photo_id' => 'photos#show'

end
