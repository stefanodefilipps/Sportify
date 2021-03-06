class ApplicationController < ActionController::Base

  #rails server -b 'ssl://localhost:3000?key=/home/biar/Desktop/localhost.key&cert=/home/biar/Desktop/localhost.crt'

  protect_from_forgery with: :exception 

  helper_method :current_user, :logged_in?, :require_user

  rescue_from CanCan::AccessDenied do |exception|
    if exception.subject.class == Team
      flash[:error] = exception.message
      redirect_to user_teams_path(current_user.id)
    elsif exception.subject.class == Match
      flash[:error] = exception.message 
      redirect_to user_matches_path(current_user.id)
    elsif exception.subject.class == User
      flash[:error] = exception.message
      redirect_to user_path(current_user.id)
    end
      
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_user
    if !logged_in?
      flash[:danger] = "You need to be logged in to perform that action"
      redirect_to root_path
    end
  end
end
