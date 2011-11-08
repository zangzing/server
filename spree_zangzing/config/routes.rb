Rails.application.routes.draw do

  namespace :admin, :path => '/service/admin/store' do

    resources :promotions do
      resources :promotion_rules
    end

    resources :zones
    resources :users
    resources :countries do
      resources :states
    end
    resources :states
    resources :tax_categories
    resources :configurations, :only => :index
    resources :products do
      collection do
        get :table, :as => :products_table
      end
      resources :product_properties
      resources :images do
        collection do
          post :update_positions
        end
      end
      member do
        get :clone
      end
      resources :variants do
        collection do
          post :update_positions
        end
      end
      resources :option_types do
        member do
          get :select
          get :remove
        end
        collection do
          get :available
          get :selected
        end
      end
      resources :taxons do
        member do
          get :select
          delete :remove
        end
        collection do
          post :available
          post :batch_select
          get  :selected
        end
      end
    end
    resources :option_types do
      collection do
        post :update_positions
      end
    end

    resources :properties do
      collection do
        get :filtered
      end
    end

    resources :prototypes do
      member do
        get :select
      end

      collection do
        get :available
      end
    end

    resource :inventory_settings
    resources :google_analytics

    resources :orders do
      member do
        put :fire
        get :fire
        post :resend
        get :history
        get :user
      end

      resources :adjustments
      resources :line_items
      resources :shipments do
        member do
          put :fire
        end
      end
      resources :return_authorizations do
        member do
          put :fire
        end
      end
      resources :payments do
        member do
          put :fire
        end
      end
    end

    resource :general_settings

    resources :taxonomies do
      member do
        get :get_children
      end

      resources :taxons
    end

    resources :reports, :only => [:index, :show] do
      collection do
        get :sales_total
      end
    end

    resources :shipments
    resources :shipping_methods
    resources :shipping_categories
    resources :tax_rates
    resource  :tax_settings
    resources :calculators
    resources :product_groups do
      resources :product_scopes
    end


    resources :trackers
    resources :payment_methods
    resources :mail_methods


    #from spree_dash
    match '/' => 'overview#index', :as => :admin
    match '/overview/get_report_data' => 'overview#get_report_data'

  end

  scope '/store' do
    resources :products

    match '/locale/set' => 'locale#set'

    resources :tax_categories


    resources :states, :only => :index

    # ezprints integration
    post   '/integration/ezprint/events'    => 'ez_print#event_handler', :as => :ezprint_event_handler

    # non-restful checkout stuff
    get   '/checkout/registration'    => 'checkout#registration', :as => :checkout_registration
    match '/checkout/signin'          => 'checkout#registration'
    post  '/checkout/registration'    => 'checkout#guest_checkout', :as => :guest_checkout
    match '/checkout/update/:state'   => 'checkout#update', :as => :update_checkout
    match '/checkout/:state'          => 'checkout#edit', :as => :checkout_state
    match '/checkout'                 => 'checkout#edit', :state => 'cart', :as => :checkout


    match '/orders/back_to_viewing_photos' => 'orders#back_to_viewing_photos', :via => :get, :as => :back_to_viewing_photos
    match '/orders/back_to_shopping' => 'orders#back_to_shopping', :via => :get, :as => :back_to_shopping

    resources :orders do
      post :populate, :on => :collection
      post :add_to_order,:on => :collection
      get  :thankyou, :on => :member

      resources :line_items
      resources :creditcards
      resources :creditcard_payments

      resources :shipments do
        member do
          get :shipping_method
        end
      end

    end
    match '/orders/:id/token/:token' => 'orders#show', :via => :get, :as => :token_order


    get '/cart', :to => 'orders#edit', :as => :cart
    put '/cart', :to => 'orders#update', :as => :update_cart
    put '/cart/checkout', :to => 'orders#checkout', :as => :checkout_cart
    put '/cart/empty', :to => 'orders#empty',  :as => :empty_cart

    resources :shipments do
       member do
         get :shipping_method
         put :shipping_method
       end
    end

    #   # Search routes
    match 's/*product_group_query' => 'products#index', :as => :simple_search
    match '/pg/:product_group_name' => 'products#index', :as => :pg_search
    match '/t/*id/s/*product_group_query' => 'taxons#show', :as => :taxons_search
    match 't/*id/pg/:product_group_name' => 'taxons#show', :as => :taxons_pg_search

    #   # route globbing for pretty nested taxon and product paths
    match '/t/*id' => 'taxons#show', :as => :nested_taxons
    #
    #   #moved old taxons route to after nested_taxons so nested_taxons will be default route
    #   #this route maybe removed in the near future (no longer used by core)
    #   map.resources :taxons
    #
    resource :account, :controller => "users"

    match '/content/cvv' => 'content#cvv'
  end

end
