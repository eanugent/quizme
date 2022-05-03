Rails.application.routes.draw do
  root to: 'welcome#index'
  resources :app
  get 'app', to: 'app#index'

  namespace 'guess_subject' do
    resources :games, only: [:index, :show, :create]
    post 'games/:id/next_question', to: 'games#next_question'
    post 'games/:id/process_answer', to: 'games#process_answer'
    get 'characters', to: 'games#characters'
  end
end
