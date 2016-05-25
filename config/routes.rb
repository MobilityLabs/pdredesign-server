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
      get 'evidence/:question_id', to: 'consensus#evidence'
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
        get '/slim', to: 'responses#show_slimmed'
        resources :scores, only: [:create, :index]
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

    resources :inventories, only: [:create, :index, :show, :update] do
      post 'reminders', to: 'inventory_reminders#create'
      patch '', to: 'inventories#mark_complete'
      post 'save_response', to: 'inventories#save_response'
      get 'participant_response', to: 'inventories#participant_response'
      resources :inventory_reminders, only: [:create]
      resources :invitations, controller: 'inventory_invitations', only: [:create]
      resources :access_requests, controller: 'inventory_access_requests', only: [:index, :create, :update]
      resource :permissions, controller: 'inventory_permissions', only: [:show, :update]
      resources :participants, controller: 'inventory_participants', only: [:create, :destroy, :index]
        get 'participants/all', to: 'inventory_participants#all'
      resources :product_entries, only: [:index, :show, :create, :update, :destroy] do
        member do
          put 'restore', to: 'product_entries#restore'
        end
      end
      resources :data_entries, only: [:index, :show, :create, :update, :destroy] do
        member do
          put 'restore', to: 'data_entries#restore'
        end
      end
      resources :learning_questions, only: [:index, :create, :update, :destroy] do
        collection do
          get 'exists', to: 'learning_questions#exists'
        end
      end

      resources :analyses, only: [:index, :show, :create, :update] do
        put '/', to: "analyses#update", on: :collection

        resources :participants, controller: 'analysis_participants', only: [:create, :destroy, :index] do
          get :all, on: :collection
        end
        resources :invitations, controller: 'analysis_invitations', only: [:create]
        resource :permissions, controller: 'analysis_permissions', only: [:show, :update]
        resource :reminders, controller: 'analysis_reminders', only: [:create]
        resources :learning_questions, only: [:index, :create, :update, :destroy] do
          get :exists, on: :collection
        end
        resources :analysis_responses, except: [:delete] do
          resources :scores, only: [:create, :index]
        end
        resources :analysis_consensus, except: [:delete, :index]

        resources :analysis_priorities, only: [:index, :create]

        get 'comparison_data', to: 'analysis_reports#comparison_data'
        get 'review_header_data', to: 'analysis_reports#review_header_data'
      end

      member do
        get :district_product_entries
      end
    end

    get '/analyses', to: 'analyses#all'

    scope '/constants' do
      get 'product_entry', to: 'constants#product_entry'
      get 'data_entry', to: 'constants#data_entry'
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
