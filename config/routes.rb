Rails.application.routes.draw do
  resources :random_sets  do
    resources :lotteries, only: [ :new, :create, :index, :edit, :update, :destroy ]
  end
  resources :users, only: %i[new create show edit update destroy]
  get "/favorite/:id/:random_set_id", to: "favorite#flip_favorite", as: "flip_favorite"
  delete "/users/:id/:random_set_id", to: "users#destroy_list", as: "user_destroy_list"
  get "/random_sets/:id/new_list", to: "random_sets#new_list", as: "new_list"
  post "/random_sets/:id/create_list", to: "random_sets#create_list", as: "create_list"
  get "/random_sets/:id/edit_list", to: "random_sets#edit_list", as: "edit_list"
  post "/random_sets/:id/update_list", to: "random_sets#update_list", as: "update_list"
  delete "/random_sets/:id/destroy_list", to: "random_sets#destroy_list", as: "destroy_list"
  get "/login/:id", to: "session#new", as: "login"
  post "/login/:id", to: "session#create", as: "create_login"
  delete "/logout/:id", to: "session#destroy", as: "logout"
  get "/home", to: "static_pages#home"
  get "/guide", to: "static_pages#guide"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "static_pages#home"
end
