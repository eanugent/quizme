Rails.application.routes.draw do
  root to: 'welcome#index'
  resources :app
  get 'app', to: 'app#index'

  resources :subjects, only: [:index, :show]

  namespace 'guess_subject' do
    resources :games, only: [:index, :show, :create]
    post 'games/:id/next_question', to: 'games#next_question'
    post 'games/:id/process_answer', to: 'games#process_answer'    
  end

  namespace 'pick_subject' do
    resources :games, only: [:index, :show, :create]
    post 'games/:id/next_question_options', to: 'games#next_question_options'
    post 'games/:id/process_question', to: 'games#process_question'
    post 'games/:id/process_guess', to: 'games#process_guess'    
  end

end
