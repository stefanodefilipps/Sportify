class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    # in questo modo mi viene cretao un nuovo user con le informazioni di facebook ma ancora devo fare la registrazione con le info essenziali
    @user = User.from_omniauth(request.env["omniauth.auth"]) 

    #nel caso di log in ho già un utente con quei dati minimi che vengono settati nel sign up quindi entro nell'if e creo la sessione
    #in seguito faccio una ridirect a root(per adesso)
    #IN SEGUITO DEVO FARE UNA REDIRECT AL CONTROLLER DEI MATCH perchè devo andare nella view che prende tutte le partite ancora da giocare o giocate dell'utente

    if !@user.just_created
      session["user_id"] = @user.id
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      puts "LOGIN CON SUCCESSO AVEVI GIA FATTO SIGNUP"
      redirect_to root_path
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      session["uid"] = request.env["omniauth.auth"]["uid"]
      redirect_to signup_path
    end
  end

  #se l'autorizzazione con facebook non va a buon fine allora stampo il messaggio di errore ricevuto e faccio una ridirect a root che 
  #tanto l'utente non è stato registrato e quindi non puo fare nulla

  def failure
    puts failure_message
    redirect_to root_path
  end

  private
     def failure_message
      exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
      error   = exception.error_reason if exception.respond_to?(:error_reason)
      error ||= exception.error        if exception.respond_to?(:error)
      error ||= (request.respond_to?(:get_header) ? request.get_header("omniauth.error.type") : request.env["omniauth.error.type"]).to_s
      error.to_s.humanize if error
     end

end