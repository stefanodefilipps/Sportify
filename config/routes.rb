Rails.application.routes.draw do
  
  root 'welcome#home'
  devise_for :user, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}
  get 'signup', to: "users#new"
  resources :users, except: [:new] do
		resources :matches
    resources :teams
  end
  get 'login', to: "sessions#new"
  post 'login', to: "sessions#create"
  delete 'logout', to: "sessions#destroy"

  get '/matches/near', to: "matches#near", as: "matches_near"


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
