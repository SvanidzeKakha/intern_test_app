Rails.application.routes.draw do
  resources :tasks
  root "tasks#index"

  
  get "up" => "rails/health#show", as: :rails_health_check
end
