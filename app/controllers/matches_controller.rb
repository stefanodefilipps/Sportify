class MatchesController < ApplicationController

	#Questa action permette di vedere in dettaglio la partita distinta da id_match definito nella url. Prima controllo che 
	#lo user partecipi effettivamente al match, altrimenti lo rimando su root. Se il test viene verificato allora:
	#-Se la partita è pp mi prendo la collezione dei gioca associati a quella partita così da avere tutti gli utenti che 
	#partecipano alla partita e anche i ruoli da poter far vedere
	#-Se la partita è pt mi prendo la collezione dei squadra associata a quella partita così da avere tutti gli utenti singoli che 
	#partecipano a quella partita. Inoltre se è stata assegnata una squadra a pt, allora dalla squadra mi prendo tutti i membro 
	#di quella squadra codì da poter risalire velocemente agli user di quella squadra che partecipano alla partita con i ruoli
	#definiti dalla loro appartenenza alla squadra
	#-Se la partita è tt, allora controllo se ho entrambe le squadre e di ogni squadra mi prendo le relazioni membro così da avere
	#i giocatori che partecipano alla partita con i loro rispettivi ruoli che coincidono con quelli della loro associazione con
	#la squadra di appartenenza

	def show
		user = User.find_by id: params[:user_id]
		@m = Match.find_by id: params[:id]
		matches = find_all_matches(user)
		if matches.count{|ma| ma.id == @m.id} == 0
			puts "User non partecipa a questa partita"
			redirect_to root_path
		end
		if @m.tipo == 1
			@players = @m.pp.gioca
		elsif @m.tipo == 2
			@single_players = @m.pt.squadra
			if m.pt.team != nil
				@team_players = @m.pt.team.membro
			end
		elsif @m.tipo == 3
			if m.tt.team.size == 1
				@players_team_1 = @m.tt.team[0].membro
			else
				@players_team_1 = @m.tt.team[0].membro
				@players_team_2 = @m.tt.team[1].membro
			end
		end
			
			
	end

	#Con questo metodo restituisco tutti i match in cui un giocatore è presente o come utente singolo o come componente di una
	#squadra. Restituisco un array di oggetti Match da cui posso poi risalire a tutti i vari componenti utili di un match se 
	#devo mostrare informazioni aggiuntive
	#dalla url mi estraggo l'id dell'user e lo trovo nel database. In seguito mi trovvo prima tutti i pp a cui partecipa e 
	#da questi mi prendo i match a cui si riferiscono. Dopo prendo tutti i pt a cui partecipa come utente singolo e mi prendo
	#il match corrispondente. In seguito mi prendo tutti i team a cui partecipa. Per ogni team mi prendo tutti i pt a cui partecipa 
	#e i match in cui è stata inserita la squadra e quindi i match pt a cui partecipa l'user tramite la squadra. Di ogni squadra
	#mi prendo anche i tt a cui partecipa e quindi il match corrispondente a cui partecipa l'utente che partecipa a quella squadra

	def index
		user = User.find_by id: params[:user_id]
		puts user
		matches_pp = user.pp
		matches_pt_s = user.pt
		user_teams = user.team
		@matches = Array.new
		matches_pp.each do |p|
			@matches.push p.match
		end
		matches_pt_s.each do |p|
			@matches.push p.match
		end
		user_teams.each do |t|
			t.pt.each do |p|
				@matches.push p.match
			end
			t.tt.each do |tt|
				@matches.push tt.match
			end
		end
	end

	#mi arriva la get a questa route e in params ho location che viene mandata come query
	#chiamo find cordinates e mi trovo lat e lng che viene passato come un array di due elementi se tutto andato bene
	#faccio una query sul modello Match per fare in modo di trovare solo le partite che sono nel raggio di quelle coordinate
	#la query la faccio tramite geokit e trovo le partite nel raggio di 3 km dalle coordinate selezionate
	#Oltre alla query spaziale sul modelli Match devo prendere anche quelle partite che non sono complete e per questo faccio
	#3 query differenti in base alla sottomodello che il modello Match è legato.
	#Considero la prima query che le altre 2 sono simili.
	#Faccio una join tra match, pp e gioca e le raggruppo per pps.id,matches.id e conto quante istanze della relazione gioca
	#contiene un certo pps.id(dato che ho fatto la group) e prendo solo quelli che il conto è minore di 10, perchè vuol dire 
	#che ci sono ancora dei posti disponibili per qualche giocatore
	#Dopo le query creo un hash che ha come chiave l'id di un match e come valore i ruoli disponibili per quel match, trovati
	#tramite la funzione di ausilio "find_roles_left" e passo questo hash come variabile di istanza così che è accessibile 
	#dalla view

	def near

		address = params[:address]
		city = params[:city]
		coordinates = find_coordinates address, city
		if coordinates.length == 1
			puts coordinates[0]
			redirect_to root_path
		else
			@matches_pp = Match.within(5, :origin => coordinates).joins(pp: :gioca).group("pps.id,matches.id").having("count(pps.id) < 10").select("pps.*, matches.*")
			@matches_pt = Match.within(5, :origin => coordinates).joins(pt: [:squadra, :team]).group("pts.id,matches.id").having("count(pts.id) < 6").select("pts.*, matches.*")
			@matches_tt = Match.within(5, :origin => coordinates).joins(tt: :team).group("tts.id,matches.id").having("count(tts.id) < 2").select("tts.*, matches.*")
			@roles_left_pp = Hash.new
			@matches_pp.each do |m_pp|
				@roles_left_pp["#{m_pp.id}"] = find_roles_left(m_pp,"pp")
			end
			@roles_left_pt = Hash.new
			@matches_pt.each do |m_pt|
				@roles_left_pt["#{m_pp.id}"] = find_roles_left(m_pt,"pt")
			end
		end
		
	end

	private 

	def find_coordinates(address, city)

		response = HTTParty.get('https://maps.googleapis.com/maps/api/geocode/json?address='+address+','+city+'&key=AIzaSyBrpRP5ZOFLfXt3NWpQIuat4zTSlQeFUbU')
		results = Array.new
		if response.code != 200
			results.insert(0,response.code)
			puts response.message
		else
			r = JSON.parse response.body
			puts r
			results.insert(0,r["results"][0]["geometry"]["location"]["lat"])
			results.insert(1,r["results"][0]["geometry"]["location"]["lng"])
		end
		return results
	end

	#Questa funzione serve per trovarmi i ruoli ancora disponibili per farli mostrare nella view
	#mi creo prima un array con tutti i ruoli disponibili, poi mi prendo pp o pt in base al parametro type
	#associati a match e da quest'ultimi mi prendo tutte le relazioni gioca che mi tengono l'informazione sul ruolo di ogni
	#giocatore. Per ogni gioca, o squadra, cancello dall'array precompilato il ruolo presente nel gioca i-esimo.
	#alla fine mi rimane un array che contiene solo i ruoli non presenti nella relazione gioca e quindi quelli ancora
	#disponibili da prenotare

	def find_roles_left(match,type)
		if type == "pp"
			roles = ["A1","P1","C11","C12","D1","A2","P2","C21","C22","D2"]
			match.pp.gioca.each do |g|
				roles.delete(g.ruolo)
			end
			return roles
		end
		if type == 'pt'
			roles = ["A","P","C1","C2","D"]
			match.pt.squadra.each do |g|
				roles.delete(g.ruolo)
			end
			return roles
		end
	end

	#Questa funzione serve per trovare tutti i match associati a un utente che ho gia trovato nel database con find_by. Molto
	#simile alla funzione svolta all'interno dell'azione index del medesimo controller

	def find_all_matches(user)
		matches_pp = user.pp
		matches_pt_s = user.pt
		user_teams = user.team
		matches = Array.new
		matches_pp.each do |p|
			matches.push p.match
		end
		matches_pt_s.each do |p|
			matches.push p.match
		end
		user_teams.each do |t|
			t.pt.each do |p|
				matches.push p.match
			end
			t.tt.each do |tt|
				matches.push tt.match
			end
		end
		return matches
	end
end
