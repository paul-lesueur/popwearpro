Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # Health check Heroku / Rails
  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboard
  get "dashboard", to: "dashboards#show", as: :dashboard

  # Profil utilisateur
  resource :profile, only: [:show, :update]

  # Établissement : un seul établissement par user
  resource :establishment, only: [:show, :edit, :update]

  # App métier Popwear Pro
  resources :customers
  resources :items

  resources :orders do
    resources :communications, only: [:create]
    collection do
      get :archives
    end
    member do
      patch :move
      patch :unarchive
      get :confirmation
    end
  end
end
