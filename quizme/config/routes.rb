Rails.application.routes.draw do
  root to: 'welcome#index'
  resources :app
  get 'app', to: 'app#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
