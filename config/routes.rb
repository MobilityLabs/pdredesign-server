PdrServer::Application.routes.draw do
  mount PdrClient::Engine, at: "/", as: :pdr_client

  devise_for :users, path: 'v1/users', controllers: { 
    sessions: 'v1/sessions', 
    registrations: 'devise/registrations', 
    invitations: 'devise/invitations' },
    defaults: { format: :json} 

  namespace :v1, defaults: { format: :json } do
    resources  :toolkits, only: :index
    resources  :rubrics, only: :index
    resources  :prospective_users, only: :create
    resources  :assessments, only: [:index, :show, :update, :create] do
      get 'report', to: 'report#show'
      resources :priorities, only: [:create, :index]
      resources :participants, except: [:update, :show]
      resources :user_invitations, only: [:create]
      resources :consensus, except: [:delete, :index]
      resources :responses, except: [:delete] do
        resources :scores, only: [:update, :create, :index]
      end
      get 'participants/all', to: 'participants#all', as: :all_participants
    end

    get  'user', to: 'user#show'
    put  'user', to: 'user#update'
    post 'user', to: 'user#create'

    get 'districts/search', to: 'districts#search'
    get 'invitation/:token', to: 'invitations#redeem'
  end
end
