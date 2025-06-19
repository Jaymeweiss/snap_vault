Rails.application.routes.draw do
  get "home/index"

  # Set root route
  root "home#index"

  # Authentication routes
  post "sessions", to: "sessions#create"    # Login
  delete "sessions", to: "sessions#destroy" # Logout
  get "sessions", to: "sessions#show"       # Current user

  # API routes
  namespace :api do
    resources :files, only: [:index, :create]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
