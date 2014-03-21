OpenstaxApi::Engine.routes.draw do
  resources :api_keys, except: [:new, :edit, :update]
  
  get 'api', to: 'static_pages#api'

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1) do
      
      resources :exercises, only: [:show, :update]
      resources :parts, only: [:show, :update, :create, :destroy]
      resources :questions, only: [:show, :update, :create, :destroy]
      resources :simple_choices, only: [:show, :update, :create, :destroy] do
        put 'sort', on: :collection
      end
      resources :combo_choices, only: [:show, :update, :create, :destroy]
      resources :combo_simple_choices, only: [:show, :create, :destroy]
      resources :logics, except: [:index]
      resources :libraries, only: [:show, :update, :new, :create, :destroy]
      resources :library_versions, only: [:show, :update, :create, :destroy] do
        get 'digest', on: :collection
      end
      
    end
  end
end
