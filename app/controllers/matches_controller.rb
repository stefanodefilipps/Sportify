class MatchesController < ApplicationController

	skip_before_action :verify_authenticity_token  

	def new
		@user = User.find_by(id: params[:user_id])
		@match = Match.new
		@match.lat = params[:lat].to_f
		@match.lng = params[:lng].to_f
		@match.campo = params[:nome]
		if params[:commit] == "SoloVsSolo"
			render :template => "/matches/playsolovssolo"
			return
		elsif params[:commit] == "SquadraVsSolo"
			render :template => "/matches/playsquadravssolo"
			return
		elsif params[:commit] == "SquadraVsSquadra"
			render :template => "/matches/playsquadravssquadra"
			return
		end
		redirect_to user_matches_path current_user
	end
	#Questa action permette di vedere in dettaglio la partita distinta da id_match definito nella url. Prima controllo che 
	#lo user partecipi effettivamente al match, altrimenti lo rimando su root. Se il test viene verificato allora:
	#-Se la partita è uu mi prendo la collezione dei gioca associati a quella partita così da avere tutti gli utenti che 
	#partecipano alla partita e anche i ruoli da poter far vedere
	#-Se la partita è pt mi prendo la collezione dei squadra associata a quella partita così da avere tutti gli utenti singoli che 
	#partecipano a quella partita. Inoltre se è stata assegnata una squadra a pt, allora dalla squadra mi prendo tutti i membro 
	#di quella squadra codì da poter risalire velocemente agli user di quella squadra che partecipano alla partita con i ruoli
	#definiti dalla loro auuartenenza alla squadra
	#-Se la partita è tt, allora controllo se ho entrambe le squadre e di ogni squadra mi prendo le relazioni membro così da avere
	#i giocatori che partecipano alla partita con i loro rispettivi ruoli che coincidono con quelli della loro associazione con
	#la squadra di auuartenenza

	def mode
		@user = User.find_by(id: params[:id])
	end

	def show
		user = User.find_by id: params[:user_id]
		@m = Match.find_by id: params[:id]
		matches = find_all_matches(user)
		if matches.count{|ma| ma.id == @m.id} == 0
			puts "User non partecipa a questa partita"
			redirect_to root_path
		end
		if @m.tipo == 1
			@players = @m.uu.gioca
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
	#dalla url mi estraggo l'id dell'user e lo trovo nel database. In seguito mi trovvo prima tutti i uu a cui partecipa e 
	#da questi mi prendo i match a cui si riferiscono. Dopo prendo tutti i pt a cui partecipa come utente singolo e mi prendo
	#il match corrispondente. In seguito mi prendo tutti i team a cui partecipa. Per ogni team mi prendo tutti i pt a cui partecipa 
	#e i match in cui è stata inserita la squadra e quindi i match pt a cui partecipa l'user tramite la squadra. Di ogni squadra
	#mi prendo anche i tt a cui partecipa e quindi il match corrispondente a cui partecipa l'utente che partecipa a quella squadra

	def index
		user = User.find_by id: params[:user_id]
		puts user
		matches_uu = user.uu
		matches_pt_s = user.pt
		user_teams = user.team
		@matches = Array.new
		matches_uu.each do |p|
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
	#Faccio una join tra match, uu e gioca e le raggruuuo per uus.id,matches.id e conto quante istanze della relazione gioca
	#contiene un certo uus.id(dato che ho fatto la group) e prendo solo quelli che il conto è minore di 10, perchè vuol dire 
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
			@matches_uu = Match.within(5, :origin => coordinates).joins(uu: :gioca).group("uus.id,matches.id").having("count(uus.id) < 10").select("uus.*, matches.*")
			@matches_pt = Match.within(5, :origin => coordinates).joins(pt: [:squadra, :team]).group("pts.id,matches.id").having("count(pts.id) < 6").select("pts.*, matches.*")
			@matches_tt = Match.within(5, :origin => coordinates).joins(tt: :team).group("tts.id,matches.id").having("count(tts.id) < 2").select("tts.*, matches.*")
			@roles_left_uu = Hash.new
			@matches_uu.each do |m_uu|
				@roles_left_uu["#{m_uu.id}"] = find_roles_left(m_uu,"uu")
			end
			@roles_left_pt = Hash.new
			@matches_pt.each do |m_pt|
				@roles_left_pt["#{m_uu.id}"] = find_roles_left(m_pt,"pt")
			end
		end
		
	end

	#TROVA CAMPI
	def findcourts
		address = params[:address].split(",")[0]
		city = params[:address].split(",")[1]
		coordinates = find_coordinates address, city
		response=HTTParty.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=calcetto&location='+coordinates[0].to_s+','+coordinates[1].to_s+
      '&radius=3000&key=AIzaSyDcD5M36rW3mAStLyxu3gsjwhOwi_LmHvI')
		r = JSON.parse response.body
		@array=Array.new
		r["results"].each do |t|
			puts t
			puts t["geometry"]["location"]["lng"]
			puts t["geometry"]["location"]["lat"]
			elem = {"lng" => t["geometry"]["location"]["lng"],"lat" => t["geometry"]["location"]["lat"],"nome" => t["name"], "address" => t["vicinity"]}
			@array.push elem
		end
	end

    #CREA EVENTO
	def create
		    if(params[:tipo]=="uu")
				params.each do |k,v|
				if(k[0]=="g" )
					if(v != "")
			  			if(User.find_by(nick: v)==nil) 
			  			puts "Giocatore #{k} non trovato!" 
			  			redirect_to user_matches_path current_user
			  			return
			  			end
			  		end
			    end
				end
				@match=Match.new
		    	@match.punt1=0
		    	@match.punt2=0
		    	@match.campo=params[:campo]
		    	@match.data=params[:data]
		    	@match.ora=params[:ora]
		    	@match.lat=params[:lat]
            	@match.lng=params[:lng]
		    	@match.tipo=1
		    	@match.creatore_id=params[:user_id]
		    	@match.save
		    	@uu=Uu.create(match_id: @match.id)
            	if(params[:g1]!="")
				gioca1=Gioca.create(user_id: User.find_by(nick: params[:g1]).id,ruolo:"portiere",squadra:"a", uu_id: @uu.id)
				User.find_by(nick: params[:g1]).gioca << gioca1
				
			end
		    if(params[:g2]!="")
		      
				gioca2=Gioca.create(user_id: User.find_by(nick: params[:g2]).id,ruolo:"difensore",squadra:"a",uu_id: @uu.id)
				User.find_by(nick: paramsì[:g2]).gioca << gioca2	
			end
		    if(params[:g3]!="")
		    	
				gioca3=Gioca.create(user_id: User.find_by(nick: params[:g3]).id,ruolo:"centro1",squadra:"a", uu_id: @uu.id)
				User.find_by(nick: params[:g3]).gioca << gioca3
			end
		    if(params[:g4]!="")
		    	
				gioca4=Gioca.create(user_id: User.find_by(nick: params[:g4]).id,ruolo:"centro2",squadra:"a", uu_id: @uu.id)
				User.find_by(nick: params[:g4]).gioca << gioca4   
			end
		    if(params[:g5]!="")
		    	
				gioca5=Gioca.create(user_id: User.find_by(nick: params[:g5]).id,ruolo:"attaccante",squadra:"a", uu_id: @uu.id)
				User.find_by(nick: params[:g5]).gioca << gioca5    
			end
		    if(params[:g6]!="")
		    	
				gioca6=Gioca.create(user_id: User.find_by(nick: params[:g6]).id,ruolo:"portiere",squadra:"b", uu_id: @uu.id)
				User.find_by(nick: params[:g6]).gioca << gioca6    
			end
		    if(params[:g7]!="")
		    	
				gioca7=Gioca.create(user_id: User.find_by(nick: params[:g7]).id,ruolo:"difensore",squadra:"b", uu_id: @uu.id)
				User.find_by(nick: params[:g7]).gioca << gioca7
			end
		    if(params[:g8]!="")
		    	
				gioca8=Gioca.create(user_id: User.find_by(nick: params[:g8]).id,ruolo:"centro1",squadra:"b", uu_id: @uu.id)
				User.find_by(nick: params[:g8]).gioca << gioca8
			end
		    if(params[:g9]!="")
				gioca9=Gioca.create(user_id: User.find_by(nick: params[:g9]).id,ruolo:"centro2",squadra:"b", uu_id: @uu.id)
				User.find_by(nick: params[:g9]).gioca << gioca9
			end
		    if(params[:g10]!="")
		    	
				gioca10=Gioca.create(user_id: User.find_by(nick: params[:g10]).id,ruolo:"attaccante",squadra:"b", uu_id: @uu.id)
				User.find_by(nick: params[:g10]).gioca << gioca10
			end
            elsif(params[:tipo]=="pt")
            	@match=Match.new
            	@pt = Pt.new
            	@pt.match = @match
		    	@match.punt1=params[:punt1]
		    	@match.punt2=params[:punt2]
		    	@match.campo=params[:campo]
		    	@match.data=params[:data]
		    	@match.ora=params[:ora]
		    	@match.lat=params[:lat]
            	@match.lng=params[:lng]
		    	@match.tipo=2
		    	@match.creatore_id=params[:user_id]
		    	params.each do |k,v|
					if(k[0]=="g" && k[1].to_i<=5)
						if(v != "")
			  				if(User.find_by(nick: v)==nil) 
			  					puts "Giocatore #{k} non trovato!" 
			  					redirect_to user_matches_path current_user
			  				return
			  			end
			  			end
			    	end
				end
				if(params[:team]!="")
					@team = Team.find_by(nome: params[:team])
					if(@team==nil) 
						puts "Team A non trovato!" 
						redirect_to user_matches_path current_user
						return
			    	end
			    	@team.pt << @pt
			    	@team.save
			    end
		    	@match.save
				@pt.save
				puts("CAZZO")
				if(params[:g1]!="")
					s1=Squadra.create(user_id: User.find_by(nick: params[:g1]).id,ruolo:"P", pt_id: @pt.id)
				end
		    	if(params[:g2]!="")
					s2=Squadra.create(user_id: User.find_by(nick: params[:g2]).id,ruolo:"D",pt_id: @pt.id)
				end
		    	if(params[:g3]!="")
					s3=Squadra.create(user_id: User.find_by(nick: params[:g3]).id,ruolo:"C1", pt_id: @pt.id)
				end
		    	if(params[:g4]!="")
					s4=Squadra.create(user_id: User.find_by(nick: params[:g4]).id,ruolo:"C2", pt_id: @pt.id)
				end
		    	if(params[:g5]!="")
					s5=Squadra.create(user_id: User.find_by(nick: params[:g5]).id,ruolo:"A", pt_id: @pt.id)
				end
            elsif(params[:tipo]=="tt")
				if(Team.find_by(nome: params[:team2])==nil) 
					flash[:notice] = "Team B non trovato!" 
				else
					if(Team.find_by(nome: params[:team1])==nil) 
						puts "Team A non trovato!" 
					else
						@match=Match.new
		    			@match.punt1=params[:punt1]
		    			@match.punt2=params[:punt2]
		    			@match.campo=params[:campo]
		    			@match.data=params[:data]
		    			@match.ora=params[:ora]
		    			@match.lat=params[:lat]
            			@match.lng=params[:lng]
		    			@match.tipo=3
		    			@match.creatore_id=params[:user_id]
		    			@match.save
						@tt=Tt.create(match_id: @match.id)
						t = Team.find_by(nome: params[:team1])
						t.tt << @tt
						t.save
						t = Team.find_by(nome: params[:team2])
						t.tt << @tt
						t.save
					end
            	end
        	end

			redirect_to user_matches_path current_user
	end

    #MATCHES NELLE VICINANZE
	def near

		address = params[:address]
		city = params[:city]
		coordinates = find_coordinates address, city
		if coordinates.length == 1
			puts coordinates[0]
			redirect_to root_path
		else
			@matches_uu = Match.within(5, :origin => coordinates).joins(uu: :gioca).group("uus.id,matches.id").having("count(uus.id) < 10").select("uus.*, matches.*")
			@matches_pt = Match.within(5, :origin => coordinates).joins(pt: [:squadra, :team]).group("pts.id,matches.id").having("count(pts.id) < 6").select("pts.*, matches.*")
			@matches_tt = Match.within(5, :origin => coordinates).joins(tt: :team).group("tts.id,matches.id").having("count(tts.id) < 2").select("tts.*, matches.*")

			@roles_left_uu = Hash.new
			@matches_uu.each do |m_uu|
				@roles_left_uu["#{m_uu.id}"] = find_roles_left(m_uu,"uu")
			end
			@roles_left_pt = Hash.new
			@matches_pt.each do |m_pt|
				@roles_left_pt["#{m_uu.id}"] = find_roles_left(m_pt,"pt")
			end
		end

	end
	
    
    #definire il punteggio a fine partita
	def endgame
		t=Time.now
        @match=Match.find_by(id: params[:match_id])
		if(t.day>= @match.data.day && t.month >=  @match.data.month && t.year>= @match.data.month && t.hour >= (@match.ora.hour + 1))
			@match.punt1=params[:punt1]
			@match.punt2=params[:punt2]
			@match.save
			puts "chiuso correttamente"
			redirect_to root_path
		else
			puts "non è ancora finito"
			redirect_to root_path
		end
	end

	#lascia recensione
	def rate

	end
    
    #salvo il match sul google calendar GOOGLE CALENDAR


	def redirect
		require 'google/apis/calendar_v3'
		session[:match_id]=params[:match_id]
		client = Signet::OAuth2::Client.new(client_options)
        redirect_to client.authorization_uri.to_s
		
	end

	def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]
    response = client.fetch_access_token!
    session[:authorization] = response
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    m=Match.find_by(id: session[:match_id])
    start = DateTime.new(m.data.year,m.data.month,m.data.day,m.ora.hour,m.ora.min)
    finish = DateTime.new(m.data.year,m.data.month,m.data.day,m.ora.hour+1,m.ora.min)
    event = Google::Apis::CalendarV3::Event.new({
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start),
      end: Google::Apis::CalendarV3::EventDateTime.new(date_time: finish ),
      summary: 'PARTITA DI CALCETTO!'
    })
    service.insert_event("primary", event)

    redirect_to root_path

    end

    
    #abbandona evento come squadra
    def leaveTeam
		@match=Match.find_by(id: params[:match_id])
		if(@match.pt!=nil)
			team=Team.find_by(nome:params[:team_name])
			if(team.capitano_id==params[:id])
				@partita=Pts_team.find_by(team_id: team.id ,pt_id: @match.pt)
				if(@partita!=nil) 
					@partita.destroy
					redirect_to root_path
				end
			end
		else
			team=Team.find_by(nome:params[:team_name])
			if(team.capitano_id==params[:id])
				@partita=Teams_tt.find_by(team_id: team.id,tt_id: @match.pt)
				if(@partita!=nil) 
					@partita.destroy
					redirect_to root_path
				end
			end	
		end
	end

	#abbandona evento come player
	def leaveplayer
		@match=Match.find_by(id: params[:match_id])
		if(@match.uu!=nil)
			@partita=Gioca.find_by(user_id: params[:id],uu_id: @match.uu)
			if(@partita!=nil) 
				@partita.destroy
				redirect_to root_path
			end
		else
			@partita=Squadra.find_by(user_id: params[:user_id],pt_id: @match.pt)
			if(@partita!=nil) 
				@partita.destroy
				redirect_to root_path
			end
		end
	end

	#cancella partita
	def destroy
		@match=Match.find_by(id: params[:match_id])
		@match.destroy
		redirect_to root_path
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


	private 

	def client_options
    {
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: callback_url
    }
    end

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
	#mi creo prima un array con tutti i ruoli disponibili, poi mi prendo uu o pt in base al parametro type
	#associati a match e da quest'ultimi mi prendo tutte le relazioni gioca che mi tengono l'informazione sul ruolo di ogni
	#giocatore. Per ogni gioca, o squadra, cancello dall'array precompilato il ruolo presente nel gioca i-esimo.
	#alla fine mi rimane un array che contiene solo i ruoli non presenti nella relazione gioca e quindi quelli ancora
	#disponibili da prenotare

	def find_roles_left(match,type)
		if type == "uu"
			roles = ["A1","P1","C11","C12","D1","A2","P2","C21","C22","D2"]
			match.uu.gioca.each do |g|
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
		matches_uu = user.uu
		matches_pt_s = user.pt
		user_teams = user.team
		matches = Array.new
		matches_uu.each do |p|
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
