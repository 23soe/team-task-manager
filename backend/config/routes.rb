Rails.application.routes.draw do
  post "/signup", to: "registrations#create"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
