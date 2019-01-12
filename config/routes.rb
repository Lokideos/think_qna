# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(:lang)', lang: /en|ru/, defaults: { lang: 'en' } do
    devise_for :users
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    resources :questions do
      resources :answers, shallow: true, only: %i[create update destroy] do
        patch :choose_best, on: :member
      end
    end

    resources :attachments, only: %i[destroy]
  end

  get '/:lang' => 'questions#index'
  root to: 'questions#index'
end
