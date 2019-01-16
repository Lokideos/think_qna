# frozen_string_literal: true

Rails.application.routes.draw do
  concern :ratable do
    member do
      patch :like
      patch :dislike
    end
  end

  scope '(:lang)', lang: /en|ru/, defaults: { lang: 'en' } do
    devise_for :users
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    resources :users, only: [] do
      get :rewards, on: :member
    end

    resources :questions, concerns: %i[ratable] do
      resources :answers, concerns: %i[ratable], shallow: true, only: %i[create update destroy] do
        patch :choose_best, on: :member
      end
    end

    resources :attachments, only: %i[destroy]
    resources :links, only: %i[destroy]
  end

  get '/:lang' => 'questions#index'
  root to: 'questions#index'
end
