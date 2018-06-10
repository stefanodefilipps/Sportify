class UsersController < ApplicationController

	before_action :require_user, except: [:new, :create]

	#questo mi deve dare la form per creare un nuovo utente
	def new
		 @user = User.new		#lo devo passare nella form per la create
	end

	def show
		@user = User.find_by(id: params[:id])
		authorize! :show, @user, :message => "Non sei autorizzato a vedere questo profilo"
		if(@user.voto != nil && @user.voto != 0)
			@rate=@user.voto / @user.tot
		else 
			@rate=0.to_f
		end
		@array=Array.new
		@user.unread_notifications.each do |n|
			n.update(read_at: Time.now)
		end
		l=Notification.where(receiver: @user.id)
		if(l!=nil )
		    l.each do |m|
		    	@array.push m
		    end
		end
	end

	#questo mi deve creare il nuovo utente dopo aver fatto il login con facebook
	#quando clicco su sign up prima mi fa la chiamata a facebook per fare autorizzazione
	#in seguito al consenso dato la callback attiva il metodo "facebook" in omniauth_callbacks_controller
	#qui viene creato il nuovo utente perchè non esiste nel database un utente con uid e provider e quindi viene creato con questi param
	#inoltre viene aggiunta anche l'email presa da facebook
	#arrivato a questo punto il nuovo utente è appena creato e quindi la chiamata a just_created da true e nel controller della callback
	#si va al ramo else dove si mette nel session i dati di facebbok appena prelevati e l'uid dell'utente facebook
	#infine si fa una ridirect a sign up che attiva new di questo ocntroller e manda la form 
	#quando si clicca su sbmit viene attivato il metodo create seguente e dopo aver fatto whitelist dei parametri da assegnare
	#mi prendo l'utente che ha l'uid salvato in session nel passo precedente (uid unico per ogni utente facebook)
	#do vita alla sessione salvando nel session l'id del nuovo user
	#mi cancello l'uid dalla session e faccio l'update dell'utente creato appena prima dalla callback di facebook
	#se tutto va bene faccio una redirect alla root(per adesso)
	#IN SEGUITO DEVO FARE UNA REDIRECT AL CONTROLLER DEI MATCH perchè devo andare nella view che prende tutte le partite ancora da giocare o giocate dell'utente
	

	def updateD
		@user=User.find_by(id: params[:id])
		authorize! :updateD, @user, :message => "Non sei autorizzato a cambiare questa descrizione"
		@user.desc=params[:desc]
		@user.save
	    redirect_to "/users/#{@user.id}"

	end
	def updateR
		i=0
		@user=User.find_by(id: params[:id])
		authorize! :show, @user, :message => "Non sei autorizzato a impostare ruoli di questo profilo"
		params.each do |k,v|
			if(v=="on" && i==0)
				@user.ruolo1=k
				@user.save
				i=1
			elsif(v=="on" && i==1)
				@user.ruolo2=k
				@user.save
			end

		end
	    redirect_to "/users/#{@user.id}"

	end
	
	def create
		par = user_params
		puts par 
		puts par["nick"]
		puts par["ruolo1"][0]
		@user = User.find_by(uid: session["uid"])
		session[:uid] = nil
		session[:user_id] = @user.id
		@user.nick = par["nick"]
		if par["ruolo1"].length == 1
			@user.ruolo1 = par["ruolo1"][0]
		else
			@user.ruolo1 = par["ruolo1"][0]
			@user.ruolo2 = par["ruolo1"][1]
		end
		@user.voto = 0
		@user.desc = ""
		@user.tot = 0
		begin
			if @user.save
				puts "Nuovo utente creato"
				redirect_to user_matches_path @user
				return
			end
		rescue ActiveRecord::RecordNotUnique => e
			flash[:error_cd] ="Creazione Utente fallita, nickname gia in uso"
			token = @user.token
		    session[:user_id] = nil
		    @user.destroy
		    redirection_url = "https://localhost:3000/"
		    redirect_to "https://www.facebook.com/logout.php?next=#{redirection_url}&access_token=#{token}"
			return
		end
		redirect_to root_path
	end

	def show_user
		@user = User.find_by(id: params[:user_id])
		@user2 = User.find_by(id: params[:id])
		if(@user2.voto != nil && @user2.voto != 0)
			@rate=@user2.voto / @user2.tot
		else 
			@rate=0.to_f
		end
	end

	def search
		@user = User.find_by(id: params[:user_id])
		if params[:nome].split(" ",1)[1]
			@array = User.where(nome: params[:nome].split(" ")[0], cognome: params[:nome].split(" ",1)[1]).or(User.where(nick: params[:nome].split(" ")[0] ))
			#@array = User.where(nome: params[:nome].split(" ")[0], cognome: params[:nome].split(" ",1)[1])
			return
		end
		@array = User.where(nome: params[:nome].split(" ")[0]).or(User.where(nick: params[:nome].split(" ")[0] ))
	end

	private

	def user_params
		params.require(:user).permit(:nick,ruolo1: [])		# Questa funzione mi serve altrimenti non posso fare mass assignment
	end
end
