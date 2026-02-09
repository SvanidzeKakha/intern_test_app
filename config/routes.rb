Rails.application.routes.draw do
  resources :imports, only: [:new, :create]

  resources :tasks
  root "imports#new"
  get "tasks/index"
  get "up" => "rails/health#show", as: :rails_health_check
end
