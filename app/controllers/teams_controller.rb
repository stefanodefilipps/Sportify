class TeamsController < ApplicationController

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
		capitano = User.find_by(id: params[:user_id])
		team = Team.new
		team.nome = params[:nome]
		team.capitano = capitano
		if team.save 					#se sono riuscito a creare la squadra allora vado avanti a creare le altre rel
			puts "Nuova squadra creata"
			giocatori = params.select {|k,v| k == "A" || k == "D" || k == "C1" || k == "P" || k == "C2"}
			capitano_presente = false
			giocatori.each do |k,v|
				if v != ""
					player = User.find_by(nick: v)
					if !player
						puts "User non esistente"
						team.destroy
						redirect_to root_path
						return
					end
					capitano_presente = capitano_presente || (capitano.id == player.id)
					mem = Membro.new
					mem.ruolo = k
					mem.team = team
					mem.user = player
					if mem.save
						player.membro << mem
						team.membro << mem
					else
						team.destroy
						puts "problemi ad aggiungere un giocatore squadra non creata"
						redirect_to root_path
					end
				end
			end
			if !capitano_presente
				puts "Capitano deve appartenere alla squadra"
				team.destroy
			end
			redirect_to root_path
			return
		end
		puts "problemi nella creazione della squadra"
		redirect_to root_path
	end
end
