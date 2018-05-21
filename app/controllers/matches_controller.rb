class MatchesController < ApplicationController

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
			@matches_pt = Match.within(5, :origin => coordinates).joins(pt: :squadra).group("pts.id,matches.id").having("count(pts.id) < 6").select("pts.*, matches.*")
			@matches_tt = Match.within(5, :origin => coordinates).joins(:tt).group("tts.id,matches.id").having("count(tts.id) < 2").select("tts.*, matches.*")
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
			roles = ["A","P","C","C","D"]
			match.pt.squadra.each do |g|
				roles.delete(g.ruolo)
			end
			return roles
		end
	end
end
