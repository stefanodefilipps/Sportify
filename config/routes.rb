Rails.application.routes.draw do
  
  root 'welcome#home'
  devise_for :user, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}
  get 'signup', to: "users#new"
  resources :users, except: [:new] do
		resources :matches
    resources :teams
  end
  resources :notifications, only: [:index]
  get 'login', to: "sessions#new"
  post 'login', to: "sessions#create"
  delete 'logout', to: "sessions#destroy"

  get '/matches/near', to: "matches#near", as: "matches_near"
  put '/users/:user_id/teams/:id/leave', to: "teams#leave", as: "teams_leave"
  put '/users/:user_id/teams/:team_id/remove/:user', to: "teams#remove", as: "teams_remove"
  put '/users/:user_id/teams/:team_id/captain/:user', to: "teams#captain", as: "teams_captain"
  put '/users/:user_id/teams/:team_id/invite', to: "teams#invite", as: "teams_invite"
  get '/notifications/:id/accept', to: "notifications#accept", as: "notifications_accept"
  get '/notifications/:id/deny', to: "notifications#deny", as: "notifications_deny"



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
