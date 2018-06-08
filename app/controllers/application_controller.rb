class ApplicationController < ActionController::Base

  #rails server -b 'ssl://localhost:3000?key=/home/biar/Desktop/localhost.key&cert=/home/biar/Desktop/localhost.crt'

  protect_from_forgery with: :exception 

  helper_method :current_user, :logged_in?

  rescue_from CanCan::AccessDenied do |exception|
    if exception.subject.class == Team
      flash[:error] = "non sei autorizzato a modificare questa squadra"
      redirect_to user_teams_path(current_user.id), :alert => exception.message
      puts exception.message
    else
      redirect_to root_path, :alert => exception.message
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
