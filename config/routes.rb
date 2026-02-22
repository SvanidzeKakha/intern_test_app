Rails.application.routes.draw do
  resources :imports, only: [:new, :create]
  resources :tasks

  resources :users, only: [:index] do
    collection do
      get :download_csv
    end
  end
  
  root "users#index"

  get "up" => "rails/health#show", as: :rails_health_check
end