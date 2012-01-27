Bingoapp::Application.routes.draw do
  root :to => 'home#index'

  resources :games, only: [:new, :create, :show] do
    resources :cards, :only => [:new, :show] do
      member do
        put 'clicked', :as => :select
        post 'join'
      end
    end

    get 'moves', :on => :member
  end
end
