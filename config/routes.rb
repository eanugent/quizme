Rails.application.routes.draw do
  root to: 'welcome#index'
  resources :app
  get 'app', to: 'app#index'

  get 'welcome/audio', to: 'welcome#audio'

  resources :subjects, only: [:index, :show]

  namespace 'guess_subject' do
    resources :games, only: [:index, :show, :create]
    post 'games/:id/next_question', to: 'games#next_question'
    post 'games/:id/process_answer', to: 'games#process_answer'    
  end

  namespace :admin do
    resource :session, only: [:show, :create, :destroy]
    resources :game_types, only: [:index]
    resources :subjects, only: [:index, :show, :create, :update] do
      collection do
        get :new_template
      end
    end
  end

  get 'admin', to: 'admin#index'
  get 'admin/*path', to: 'admin#index'

  namespace 'pick_subject' do
    resources :games, only: [:index, :show, :create]
    resources :game_rooms, only: [:create, :show]
    post 'games/:id/next_question_options', to: 'games#next_question_options'
    post 'games/:id/process_question', to: 'games#process_question'
    post 'games/:id/process_guess', to: 'games#process_guess'
    get 'game_types', to: 'games#game_types'
    post 'game_rooms/add_player', to: 'game_rooms#add_player'
  end

end
