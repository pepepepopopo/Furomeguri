Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resources :maps, only: [:index] do
    collection do
      get "location_search"
    end
  end

  resources :itineraries, only: %i[index new create edit update show destroy] do
    resources :itinerary_blocks, only: %i[create update destroy]
  end
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "maps#index"

  namespace :api do
    resources :default_locations, only: [:index]
  end
end
