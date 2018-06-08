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
  get '/users/:user_id/show/:id', to: "users#show_user", as: "user_show_user"
  get '/users/:user_id/search/', to: "users#search", as: "user_search"

  post '/users/:id/matches/:match_id/leavet/:team_id', to: "matches#leaveteam"
  get '/users/:id/matches/:match_id/leavep', to: "matches#leaveplayer"
  get '/users/:id/matches/:match_id/destroy', to: "matches#destroy"
  post '/users/:id/matches/:match_id/endgame', to: "matches#endgame"
  post '/users/:id/matches/:match_id/rate', to: "matches#rate"
  post 'findplaces', to: "matches#findcourts"

  get '/users/:id/matches/:match_id/redirect', to: 'matches#redirect', as: 'redirect'
  get '/callback', to: 'matches#callback', as: 'callback'
  
  post '/users/:id/updateD', to: "users#updateD"
  post '/users/:id/updateR', to: "users#updateR"

  get '/matches/near', to: "matches#near", as: "matches_near"
  put '/users/:user_id/teams/:id/leave', to: "teams#leave", as: "teams_leave"
  put '/users/:user_id/teams/:team_id/remove/:user', to: "teams#remove", as: "teams_remove"
  put '/users/:user_id/teams/:team_id/captain/:user', to: "teams#captain", as: "teams_captain"
  put '/users/:user_id/teams/:team_id/invite', to: "teams#invite", as: "teams_invite"
  get '/notifications/:id/accept', to: "notifications#accept", as: "notifications_accept"
  get '/notifications/:id/deny', to: "notifications#deny", as: "notifications_deny"
  get '/users/:id/matches/mode/new', to: "matches#mode", as: "new_mode_user_match"
  put '/users/:id/matches/:match_id/deleteplayer/:user_id_2', to: "matches#deleteplayer", as: "matches_delete_player"
  put '/users/:id/matches/:match_id/deleteteam/:team_id', to: "matches#deleteteam", as: "matches_delete_team"



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
