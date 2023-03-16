require 'sidekiq/web'
Sidekiq::Web.use AccountElevator

Rails.application.routes.draw do

  concern :iiif_search, BlacklightIiifSearch::Routes.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :oai_provider, BlacklightOaiProvider::Routes.new

  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?

  authenticate :user, lambda { |u| u.is_superadmin || u.is_admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  if Settings.multitenancy.enabled
    constraints host: Account.admin_host do
      get '/account/sign_up' => 'account_sign_up#new', as: 'new_sign_up'
      post '/account/sign_up' => 'account_sign_up#create'
      get '/', to: 'splash#index', as: 'splash'

      # pending https://github.com/projecthydra-labs/hyrax/issues/376
      get '/dashboard', to: redirect('/')

      namespace :proprietor do
        resources :accounts
        resources :users
      end
    end
  end

  get 'status', to: 'status#index'

  mount BrowseEverything::Engine => '/browse'
  resource :site, only: [:update] do
    resources :roles, only: [:index, :update]
    resource :labels, only: [:edit, :update]
    resource :contact, only: [:edit, :update]
  end

  root 'hyrax/homepage#index'

  devise_for :users, controllers: { invitations: 'hyku/invitations', registrations: 'hyku/registrations' }
  mount Qa::Engine => '/authorities'

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  mount Hyrax::Engine, at: '/'
  if Settings.bulkrax.enabled
    mount Bulkrax::Engine, at: '/'
  end

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new

  curation_concerns_basic_routes

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

    concerns :searchable
    concerns :range_searchable

  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
    concerns :iiif_search
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  namespace :admin do
    resource :account, only: [:edit, :update]
    resource :work_types, only: [:edit, :update]
    resources :users, only: [:destroy]
    resources :groups do
      member do
        get :remove
      end

      resources :users, only: [:index], controller: 'group_users' do
        collection do
          post :add
          delete :remove
        end
      end
    end
  end

  get 'resources' => 'hyrax/pages#show', key: 'resources'

  # Upload a collection thumbnail
  post "/dashboard/collections/:id/delete_uploaded_thumbnail", to: "hyrax/dashboard/collections#delete_uploaded_thumbnail", as: :delete_uploaded_thumbnail
end
