Rails.application.routes.draw do
  get "communications/create"
  get "orders/index"
  get "orders/show"
  get "orders/new"
  get "orders/create"
  get "orders/edit"
  get "orders/update"
  get "orders/destroy"
  get "items/index"
  get "items/show"
  get "items/new"
  get "items/create"
  get "items/edit"
  get "items/update"
  get "items/destroy"
  get "customers/index"
  get "customers/show"
  get "customers/new"
  get "customers/create"
  get "customers/edit"
  get "customers/update"
  get "customers/destroy"
  get "dashboards/show"
  devise_for :users

  root to: "pages#home"

  # Health check Heroku / Rails
  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboard
  get "dashboard", to: "dashboards#show", as: :dashboard

  # App métier Popwear Pro
  resources :customers
  resources :items
  resources :orders do
    resources :communications, only: [:create]
  end
end
