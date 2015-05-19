PdrServer::Application.routes.draw do
  mount PdrClient::Engine, at: "/", as: :pdr_client
  mount RailsAdmin::Engine, at: '/admin', as: 'rails_admin'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users, path: 'v1/users', controllers: {
    sessions: 'v1/sessions',
    registrations: 'devise/registrations',
    invitations: 'devise/invitations' },
    defaults: { format: 'json'}

  namespace :v1, defaults: { format: 'json' } do
    resources :faqs, only: [:index]

    get  '/organizations/search', to: 'organizations#search'
    resources  :organizations, only: [:create, :update, :show] do
      post 'logo', to: 'organizations#upload'
    end
    resources  :district_messages, only: [:create]
    resources  :tools, only: [:index, :create]
    resources  :rubrics, only: :index
    resources  :categories, only: :index
    resources  :prospective_users, only: :create
    resources  :assessments, only: [:index, :show, :update, :create] do
      get 'report', to: 'report#show'
      resources :reminders, only: [:create]
      resources :access_request, only: [:create]
      resources :priorities, only: [:create, :index]
      resources :participants, except: [:update, :show] do
        get 'mail', to: 'participants#mail'
      end
      resources :user_invitations, only: [:create]
      resources :consensus, except: [:delete, :index] do
        get 'consensus_report', to: 'report#consensus_report'
        resources :participants, :only => [] do
          get 'report', to: 'report#participant_consensu_report'
        end
      end
      resources :responses, except: [:delete] do
        resources :scores, only: [:update, :create, :index]
      end
      get 'participants/all', to: 'participants#all', as: :all_participants
      resources :permissions, only: [:index, :update, :show], controller: 'assessments_permissions' do
        collection do
          get :current_level
        end
      end
    end

    get  'user', to: 'user#show'
    put  'user', to: 'user#update'
    post 'user', to: 'user#create'
    post 'user/reset', to: 'user#reset'
    post 'user/request_reset', to: 'user#request_reset'

    get  'districts/search',  to: 'districts#search'
    post 'invitations/:token', to: 'invitations#redeem'
    get  'invitations/:token', to: 'invitations#show'

    post 'access/:token/grant', to: 'access#grant'
  end
end
