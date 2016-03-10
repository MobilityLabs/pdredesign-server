PdrServer::Application.routes.draw do
  mount RailsAdmin::Engine, at: '/admin', as: 'rails_admin'
  scope module: 'pdr_client' do
    root to: 'pdr_client#index'
    post 'v1/assessments/:assessment_id/reports/consensus_report', to: 'reports#consensus_report'
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users, path: 'v1/users',
             controllers: {
                 sessions: 'v1/sessions',
                 registrations: 'devise/registrations',
                 invitations: 'devise/invitations'},
             defaults: {format: 'json'}

  namespace :v1, defaults: {format: 'json'} do
    resources :faqs, only: [:index]

    get '/organizations/search', to: 'organizations#search'
    resources :organizations, only: [:create, :update, :show] do
      post 'logo', to: 'organizations#upload'
    end
    resources  :district_messages, only: [:create]
    resources  :tools, only: [:index, :create]
    resources  :rubrics, only: :index
    resources  :categories, only: :index
    resources  :prospective_users, only: :create
    resources  :assessments, only: [:index, :show, :update, :create] do
      collection do
        resources :shared, controller: 'shared_assessments', only: [:show], param: :token do
          get :report, to: 'shared_report#show'
          resources :priorities, controller: 'shared_priorities', only: [:index]
        end
      end
      get 'report', to: 'report#show'
      resources :reminders, only: [:create]
      resources :access_request, only: [:create]
      resources :priorities, only: [:create, :index]

      resources :participants, except: [:update, :show] do
        get 'mail', to: 'participants#mail'
      end

      resources :learning_questions, only: [:index, :create, :update, :destroy] do
        collection do
          get 'exists', to: 'learning_questions#exists'
        end
      end

      resources :user_invitations, only: [:create]
      resources :consensus, except: [:delete, :index] do
        get 'consensus_report', to: 'report#consensus_report'
        resources :participants, only: [] do
          get 'report', to: 'report#participant_consensu_report'
        end
      end

      resources :responses, except: [:delete] do
        resources :scores, only: [:update, :create, :index]
      end

      get 'participants/all', to: 'participants#all', as: :all_participants

      resources :permissions, only: [:index, :update, :show], controller: 'assessments_permissions' do
        member do
          put :accept
          put :deny
        end

        collection do
          get :all_users
          get :current_level
        end
      end
    end

    get 'user', to: 'user#show'
    put 'user', to: 'user#update'
    post 'user', to: 'user#create'
    post 'user/reset', to: 'user#reset'
    post 'user/request_reset', to: 'user#request_reset'

    get 'districts/search', to: 'districts#search'
    post 'invitations/:token', to: 'invitations#redeem'
    get 'invitations/:token', to: 'invitations#show'

    post 'access/:token/grant', to: 'access#grant'
  end
end
