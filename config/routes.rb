Rails.application.routes.draw do
  mount Resque::Server.new, at: '/admin/resque', as: 'resque_web'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :championships, :only => [:index, :show] do
    resources :leagues, :only => [:index, :show] do
      get :ranking
    end
    resources :rounds, :only => [:show]
  end

  resources :user, :only => [:index] do
    collection do
      get :leagues
      post :leagues, action: :add_league, as: :add_league
      delete :leagues, action: :delete_league, as: :delete_league
    end

    collection do
      resources :rounds, :only => [] do
        get :battles, controller: :user
        get :bets, controller: :user
        post :bets, controller: :user, action: :bet
      end
    end
  end

  resources :users, :only => [] do
    resources :rounds, :only => [] do
      get :bets, controller: :users
    end
  end

  get "partials/:name.html", to: "home#show_partial"

  root 'home#index'
end
