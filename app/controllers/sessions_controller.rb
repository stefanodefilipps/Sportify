class SessionsController < ApplicationController

  def new
  end
  
  def create 
  end

  #in realtà nel session controller mi serve solo il destroy session dove modifico session 
  #e devo aggiungere che fa il log out da facebook

  #Quando voglio fare il log out prima vedo se ho fatto il log_in altrimenti poi non trovo utente e faccio operazioni us nil. Altrimenti
  #mi trovo l'utente che sta facendo attualmente la richiesta  emi prendo il token di facebook preso al log in. In seguito tolgo l'id
  #dalla session cosi da distruggere la sessione e poi faccio la chiamata alla url di facebook per il log out in cui devo passare la
  #url della ridirect dopo il log out da facebook e l'access token dato all'utente
  
  def destroy
    if(!logged_in?)                           
      puts "YOU ARE NOT LOGGED IN"
      redirect_to root_path
      return
    end
    user = User.find_by(id: session[:user_id])
    token = user.token
    session[:user_id] = nil
    flash[:success] = "You have successfully logged out"
    redirection_url = "https://localhost:3000/"
    redirect_to "https://www.facebook.com/logout.php?next=#{redirection_url}&access_token=#{token}"    
  end

end
