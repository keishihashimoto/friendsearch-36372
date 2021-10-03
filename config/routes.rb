Rails.application.routes.draw do
  resources :users
  get "/" ,to: "users#index"
  get root to: "users#index"
end
