class TeamsController < ApplicationController

	#before_action :inizializza_flash
	skip_before_action :verify_authenticity_token

	def new
		@team = Team.new
		@user = User.find_by(id: params[:user_id])
	end

	#questa funzione serve per creare una nuova squadra con utenti aggiunti tramite nickname. Prima mi prendo l'id dalla url che diventa il
	#capitano della squadra. Mi cerco l'user che diventa capitano, mi creo una nuova squadra e setto il nome, che deve essere unico e il 
	#capitano. In seguito provo a salvare e se ci sono problemi mando un messaggio. Se va bene ho creato la squadra e allora da params mi 
	#prendo l'hash formato solo dagli elementi che mi servono  e ciclo su quell'hash. Se ho un valore diverso da "" allora vuol dire che
	#il creatore ha specificato un utente da aggiungere alla squadra e mi da il nickname tramite cui posso trovarlo nel database.
	#Quindi mi prendo il giocatore da aggiungere alla squadra, creo una nuova entità di membro e ci passo il ruolo a con cui deve giocare
	#che corrisponde alla chiave dell'hash perchè sarà il nome dell'input nella form, e ci associo il team e il giocatore e provo a salvare
	#Se ci sono problemi ad aggiungere un giocatore alla squadra, allora elimino proprio la squadra che in cascata mi elimina tutte le altre
	#relazioni con membro. Devo anche controllare che il creatore, ovvero il capitano della squadra, appartenga alla squadra stessa e quindi
	#uso la variabile booleana "capitano_presente" che controlla se l'id del capitano trovato precedentemente coincide con qualche id dei
	#player che vengono ricercati in giocatori.each.
	#Se un utente specificato non esiste allora cancello la squadra

	def create
		@capitano = User.find_by(id: params[:user_id])
		@team = Team.new
		@team.nome = params[:nome]
		@team.capitano = @capitano
		giocatori = params.select {|k,v| k == "A" || k == "D" || k == "C1" || k == "P" || k == "C2"}
		puts giocatori.select{|k,v| v == @capitano.nick}.empty?
		if giocatori.select{|k,v| v == @capitano.nick}.empty?
			flash[:error_cd] ="Creazione Fallita. Il capitano deve essere in squadra"
			puts "Capitano deve essere in squadra"
			redirect_to user_teams_path(current_user.id)
			return
		end
		giocatori.each do |k,v|
			if v != ""
				if v == @capitano.nick
					mem = Membro.new
					mem.ruolo = k
					mem.team = @team
					mem.user = @capitano
					begin 										#provo a salvare membro ma devo controllare che l'user non sia gia presente nella squadra altrimenti postgres
						mem = mem.save							#mi lancia l'errore che il record non è unico e quindi se si verifica in questo punto devo cancellare la squadra
					rescue ActiveRecord::RecordNotUnique => e
						puts e.message.upcase
						flash[:error_cd] ="Creazione Team fallita, utente presente più volte o due utenti con stesso ruolo"
						@team.destroy
						redirect_to user_teams_path(current_user.id)
						return
					end
					if !mem
						@team.destroy
						flash[:error_cd] ="problemi ad aggiungere un giocatore squadra non creata"
						puts "problemi ad aggiungere un giocatore squadra non creata"
						redirect_to user_teams_path(current_user.id)
						return
					end
				else
					player = User.find_by(nick: v)
					if !player
						flash[:error_cd] = "User #{v} non esistente"
						puts "User non esistente"
						@team.destroy
						redirect_to user_teams_path(current_user.id)
						return
					end

					notifica = Notification.new
					notifica.sender = @capitano
					notifica.receiver = player
					notifica.data = Date.today
					notifica.ora = Time.now
					notifica.msg = "#{@capitano.nick} ti ha invitato a partecipare alla squadra #{@team.nome}"
					notifica.tipo = 2
					if !notifica.save
						flash[:error_cd] ="Impossibile invitare #{player.nick}"
						puts "Impossibile invitare #{player.nick}"
					else
						notifica_squadra = Sq.new
						notifica_squadra.notification = notifica
						notifica_squadra.team = @team
						notifica_squadra.ruolo = k
						if !notifica_squadra.save
							flash[:error_cd] ="Impossibile invitare #{player.nick}"
							puts "Impossibile invitare #{player.nick}"
							notifica.destroy
						else
							flash[:success_cd] = "Giocatore #{player.nick} invitato alla squadra"
							puts "Giocatore #{player.nick} invitato alla squadra"
						end
					end
				end

				#mem = Membro.new
				#mem.ruolo = k
				#mem.team = @team
				#mem.user = player
				#begin 										#provo a salvare membro ma devo controllare che l'user non sia gia presente nella squadra altrimenti postgres
				#	mem = mem.save							#mi lancia l'errore che il record non è unico e quindi se si verifica in questo punto devo cancellare la squadra
				#rescue ActiveRecord::RecordNotUnique => e
				#	puts e.message.upcase
				#	@team.destroy
				#	redirect_to user_teams_path(current_user.id)
				#	return
				#end
				#if !mem
				#	@team.destroy
				#	puts "problemi ad aggiungere un giocatore squadra non creata"
				#	redirect_to user_teams_path(current_user.id)
				#end
			end
		end
		if @team.save
			@capitano.roles << :captain
			if @capitano.save
				flash[:success_cd] = "Nuova squadra creata con successo"
				puts "Nuova squadra creata con successo"
				redirect_to user_teams_path(current_user.id)
				return
			end
		end
		flash[:error_cd] = "problemi nella creazione della squadra"
		puts "problemi nella creazione della squadra"
		redirect_to user_teams_path(current_user.id)
	end

	#Questa funzione serve per mostrare tutte le squadre relative a un utente passato nella url. Se id nella url è diversa da quella
	#della session user id allora faccio una ridirect all'index uder id nella session perchè un utente può vedere solo le proprie
	#squadre

	def index
		@user = User.find_by(id: params[:user_id])
		if !@user
			flash[:error] = "User non esistente"
			puts "User non esistente"
			redirect_to root_path
			return		
		end
		if @user.id != current_user.id
			redirect_to user_teams_path(current_user)
			return
		end
		if !@user
			flash[:error] = "User non esistente"
			puts "User non esistente"
			redirect_to root_path
			return		
		end
		@teams = @user.team
	end

	#Questa funzione serve per mostrare dettagli su una squadra di cui sono partecipe. Il metodo authorize di cancan serve
	#per assicurare che un utente possa ottenere informazioni su una squadra solo se ne è un membro altrimenti no

	def show
		@user = User.find_by(id: params[:user_id])
		if !@user
			puts "User non esistente"
			flash[:error] = "User non esistente"
			redirect_to user_teams_path(current_user.id)
			return		
		end
		@team = Team.find_by(id: params[:id])
		if !@team
			flash[:error] = "Team non esistente"
			puts "squadra non esistente"
			redirect_to user_teams_path(current_user.id)
			return
		end
		authorize! :show,@team, :message => "Non sei autorizzato a vedere questa partita"
	end

	def edit
		@team = Team.find_by(id: params[:id])
		if !@team
			redirect_to user_teams_path(current_user.id)
			return
		end
		@user = User.find_by(id: params[:user_id])
		authorize! :edit, @team, :message => "Non sei autorizzato a modificare questa partita"
		puts "Sei capitano della squadra edit"
	end

	def update
		@team = Team.find_by(id: params[:id])
		if !@team
			flash[:error] = "Team non esistente"
			return
		end
		authorize! :edit, @team, :message => "Non sei autorizzato a modificare questa partita"
		puts "sei capitano della squadra update"
		if params[:nome] == ""
			flash[:error] = "Aggiungere un nuovo nome"
			puts "Aggiungere un nuovo nome"
			return
		end
		@team.nome = params[:nome]
		if @team.save
			flash[:success] = "Nome cambiato con successo"
			puts "Nome cambiato con successo"
			return
		end
		flash[:error] = "Impossibile cambiare il nome della squadra"
		puts "Impossibile cambiare il nome della squadra"
	end

	def destroy
		@team = Team.find_by(id: params[:id])
		if !@team
			flash[:error_cd] = "Team Non esistente"
			redirect_to user_teams_path(current_user.id)
			return
		end
		authorize! :destroy, @team, :message => "Non sei autorizzato a eliminare questa partita"
		@team.destroy
		flash[:success_cd] = "Team #{@team.nome} distrutta con successo"
		puts "distrutta"
		redirect_to user_teams_path(current_user.id)
	end

	#Questa funzione serve a un tente ch partecipa a una squadra di abbandonarla. Prima controllo che l'utente passato nella
	#url esista nel database e stessa cosa per la squadra che si sta tentando id abbandonare. In seguito si controlla se effettivamente
	#l'utente partecipa a quella squadra e in caso affermativo distruggo l'associazione membro che lega quell'utente e quella squadra
	#il metodo authorize di cancan serve ad assicurarmi che mi sto cancellando da una squadra a cui appartengo

	def leave
		@user = User.find_by(id: params[:user_id])
		if !@user
			puts "User non esistente"
			flash[:error] = "User non esistente"
			redirect_to root_path
			return		
		end
		if @user != current_user
			puts "User non esistente 2"
			flash[:error] = "User non esistente"
			redirect_to user_teams_path(current_user.id)
			return
		end
		@team = Team.find_by(id: params[:id])
		if !@team
			flash[:error] = "Team non esistente"
			puts "squadra non esistente"
			redirect_to user_teams_path(current_user.id)
			return
		end
		authorize! :leave, @team, :message => "Non sei autorizzato ad abbandonare questa partita"
		@team.membro.where(user_id: @user.id)[0].destroy
		flash[:success] = "Ti sei eliminato con successo dalla squadra"
		puts "utente cancellato dalla squadra"
		redirect_to user_teams_path(@user)
	end

	#Questa route serve al capitano di una squadra per eliminare un membro della squadra

	def remove
		@user = User.find_by(id: params[:user_id])
		if !@user
			flash[:error] = "User non esistente"
			puts "User non esistente"
			#redirect_to user_team_path current_user, @team
			return		
		end
		if @user != current_user
			flash[:error] = "User non esistente"
			puts "User non esistente 2"
			#redirect_to user_team_path current_user, @team
			return
		end
		@team = Team.find_by(id: params[:team_id])
		if !@team
			flash[:error] = "Team non esistente"
			puts "squadra non esistente"
			#redirect_to user_team_path current_user, @team
			return
		end
		@user_to_remove = User.find_by(id: params[:user])
		if !@user_to_remove
			flash[:error] = "User da rimuovere non esistente"
			puts "User da rimuovere non esistente"
			redirect_to user_team_path current_user, @team
			return		
		end
		authorize! :remove, @team, :message => "Non sei autorizzato a rimuovere questo utente"
		if is_in_team?(@user_to_remove,@team)
			@team.membro.where(user_id: @user_to_remove.id).destroy_all
			#redirect_to user_team_path current_user, @team
			flash[:success] = "#{@user_to_remove.nick} è stato eliminato"
			puts "#{@user_to_remove.nick} è stato eliminato"
			return
		end
		flash[:error] = "#{@user_to_remove.nick} non è presente nella squadra"
		puts "#{@user_to_remove.nick} non è presente nella squadra"
		#redirect_to user_team_path current_user, @team
	end

#Questa route serve per passare il ruolo di capitano a un altro utente della squadra


	def captain
		@user = User.find_by(id: params[:user_id])
		if !@user
			flash[:error] = "User non esistente"
			puts "User non esistente"
			#redirect_to user_team_path current_user, @team
			return		
		end
		if @user != current_user
			flash[:error] = "User non esistente"
			puts "User non esistente 2"
			#redirect_to user_team_path current_user, @team
			return
		end
		@team = Team.find_by(id: params[:team_id])
		if !@team
			flash[:error] = "Team non esistente"
			puts "squadra non esistente"
			#redirect_to user_team_path current_user, @team
			return
		end
		@new_captain = User.find_by(id: params[:user])
		if !@new_captain
			flash[:error] = "Nuovo Capitano non esistente"
			puts "Nuovo capitano non esistente"
			#redirect_to user_team_path current_user, @team
			return		
		end
		authorize! :remove, @team, :message => "Non sei autorizzato a cambiare il capitano di questa squadra"
		if is_in_team? @new_captain, @team
			@team.capitano = @new_captain
			if @team.save
				flash[:success] = "Ruolo Capitano passato a #{@new_captain.nick}"
				puts "Ruolo passato a #{@new_captain.nick}"
				#redirect_to user_team_path current_user, @team
				return
			end
			flash[:error] = "impossibile passare il ruolo di capitano"
			puts "impossibile passare il ruolo di capitano"
			#redirect_to user_team_path current_user, @team
		end
		flash[:error] = "#{@new_captain.nick} non è nella squadra"
		#redirect_to user_team_path current_user, @team
	end

	def invite
		@user = User.find_by(id: params[:user_id])
		if !@user
			flash[:error] = "User non esistente"
			puts "User non esistente"
			#redirect_to user_team_path current_user, @team
			return		
		end
		if @user != current_user
			flash[:error] = "User non esistente"
			puts "User non esistente 2"
			#redirect_to user_team_path current_user, @team
			return
		end
		@team = Team.find_by(id: params[:team_id])
		if !@team
			flash[:error] = "Team non esistente"
			puts "squadra non esistente"
			#redirect_to user_team_path current_user, @team
			return
		end
		authorize! :invite, @team, :message => "Non sei autorizzato a invitare utente in questa squadra"


		nick = ""
		ruolo = ""
		params.select {|k,v| k == "A" || k == "D" || k == "C1" || k == "P" || k == "C2"}.each do |k,v|
			ruolo = k
			nick = v
		end
		@new_member = User.find_by(nick: nick)
		if !@new_member
			flash[:error] = "User da invitare non esistente"
			puts "User non esistente"
			#redirect_to user_team_path current_user, @team
			return		
		end
		notifica = Notification.new
		notifica.sender = @team.capitano
		notifica.receiver = @new_member
		notifica.data = Date.today
		notifica.ora = Time.now
		notifica.msg = "#{@team.capitano.nick} ti ha invitato a partecipare alla squadra #{@team.nome}"
		notifica.tipo = 2
		if !notifica.save
			flash[:error] = "Impossibile invitare #{@new_member.nick}"
			puts "Impossibile invitare #{@new_member.nick}"
			return
		else
			notifica_squadra = Sq.new
			notifica_squadra.notification = notifica
			notifica_squadra.team = @team
			notifica_squadra.ruolo = ruolo
			if !notifica_squadra.save
				flash[:error] = "Impossibile invitare #{@new_member.nick}"
				puts "Impossibile invitare #{@new_member.nick}"
				notifica.destroy
				return
			else
				flash[:success] = "Giocatore #{@new_member.nick} invitato alla squadra"
				puts "Giocatore #{@new_member.nick} invitato alla squadra"
				return
			end
		end
		#mem = Membro.new
		#mem.ruolo = ruolo
		#mem.user = @new_member
		#mem.team = @team
		#begin 										#provo a salvare membro ma devo controllare che l'user non sia gia presente nella squadra altrimenti postgres
		#	mem = mem.save							#mi lancia l'errore che il record non è unico e quindi se si verifica in questo punto devo cancellare la squadra
		#rescue ActiveRecord::RecordNotUnique => e
		#	puts e.message.upcase
		#	#redirect_to user_teams_path(current_user.id)
		#	return
		#end
		#if mem
		#	puts "#{@new_member.nick} aggiunto alla squadra"
		#	#redirect_to user_team_path current_user, @team
		#	return		
		#end
		#puts "Impossibile aggiungere #{@new_member.nick} alla squadra"
		#redirect_to user_team_path current_user, @team
	end

	private

	def is_in_team?(user,team)
		return team.user.where(id: user.id)[0]
	end

end
