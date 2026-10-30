# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?

  #if Rails.env.production?
  #  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  #end

  post '/graphql', to: 'graphql#execute'

  root 'welcome#index'

  # match 'path', :to => 'controller#action', :via => [:get, :post]

  namespace :api do
    namespace :v1 do
      
      get 'configs', to: 'configs#index'
      
      resources :books do
        collection do
          get '/genre/:genre(/:status)', to: 'books#categories', as: 'filter'
          # match '/:status', to: 'posts#index', as: 'filter'
        end
      end

      # resources :books    # , only: [:index, :create]
      resources :authors # , only: [:index, :create]
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
