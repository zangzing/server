Rails.application.routes.draw do

  namespace :admin, :path => '/service/admin/store' do

    resources :zones
    resources :users
    resources :countries do
      resources :states
    end
    resources :states
    resources :tax_categories
    resources :configurations, :only => :index
    resources :products do
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

  # REMOVE THESE ROUTES FROM SPREE
  match "/admin" => redirect("/404.html")
  #match "/admin/*other" => redirect("/404.html")
  #from spree_dash
  #match '/admin/overview/get_report_data' => redirect("/404.html")


  scope '/service/store' do

    resources :states, :only => :index
    
    # non-restful checkout stuff
    match '/checkout/update/:state' => 'checkout#update', :as => :update_checkout
    match '/checkout/:state' => 'checkout#edit', :as => :checkout_state
    match '/checkout' => 'checkout#edit', :state => 'address', :as => :checkout

    resources :orders do
      post :populate, :on => :collection
      match :add_photo,:on => :collection


      resources :line_items
      resources :creditcards
      resources :creditcard_payments

      resources :shipments do
        member do
          get :shipping_method
        end
      end

    end
    match '/cart', :to => 'orders#edit', :via => :get, :as => :cart
    match '/cart', :to => 'orders#update', :via => :put, :as => :update_cart
    match '/cart/empty', :to => 'orders#empty', :via => :put, :as => :empty_cart
  end

end
