# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  use_doorkeeper
  concern :ratable do
    member do
      patch :like
      patch :dislike
      patch :unlike
    end
  end

  concern :commentable do
    resources :comments, shallow: true, only: %i[create destroy]
  end

  devise_for :users, only: :omniauth_callbacks, controllers: { omniauth_callbacks: 'oauth_callbacks' }

  scope '(:lang)', lang: /en|ru/, defaults: { lang: 'en' } do
    devise_for :users, skip: :omniauth_callbacks

    get 'create_email/show'
    post 'create_email/create'

    resources :users, only: [] do
      get :rewards, on: :member
    end

    resources :questions, concerns: %i[ratable commentable] do
      resources :answers, concerns: %i[ratable commentable], shallow: true, only: %i[create update destroy] do
        patch :choose_best, on: :member
      end

      patch :subscribe, on: :member
    end

    resources :attachments, only: %i[destroy]
    resources :links, only: %i[destroy]

    namespace :api do
      namespace :v1 do
        resources :profiles, only: %i[index] do
          get :me, on: :collection
        end

        resources :questions, except: %i[new edit] do
          resources :answers, shallow: true, except: %i[new edit]
        end
      end
    end
  end

  get '/:lang' => 'questions#index'
  root to: 'questions#index'
end
