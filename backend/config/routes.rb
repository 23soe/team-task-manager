Rails.application.routes.draw do
  post "/signup", to: "registrations#create"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  get "/me", to: "sessions#me"
  get "/workspaces", to: "workspaces#index"

  namespace :api do
    namespace :v1 do
      resources :workspaces, only: [:index, :show] do
        resources :tasks, only: [:index] 
      end
    end
  end

  resources :organizations, only: [:index]
end
