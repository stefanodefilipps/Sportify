class User < ApplicationRecord

	has_many :gioca 
	has_many :uu, through: :gioca
	has_many :squadra 
	has_many :pt, through: :squadra
	has_many :membro
	has_many :team, through: :membro
	has_many :compagni, class_name: "User"
	has_many :notifications

	 # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
	devise :omniauthable, :omniauth_providers => [:facebook]

	acts_as_user :roles => [ :captain, :match_creator ]
	

	#la funzione seguente serve per trovare un utente che ha ia fatto il login con facebbok o a crearne uno con le credenziali minime
	#se non trovato allora ne creo uno in cui ci salvo l'auth.provider e l'auth.uid
	#l'email in realtà non mi serve e sara da togliere
	#devo anche prendermi il nome, il cognome e l'immagine da salvare nel database
	#inoltre devo prendermi anche il token di facebook dato al momento dell'autenticazione perchè mi serve in caso di voler fare il log-out

	def self.from_omniauth(auth) 
		where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
			user.token = auth.credentials.token
			user.nome = auth.info.first_name
			user.cognome = auth.info.last_name
			user.img = auth.info.image
		end
	end

	def self.new_with_session(params, session) 
		super.tap do |user|
			if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
				user.email = data["email"] if user.email.blank?
	      	end
    	end
	end

	def just_created()
		desc == nil && nick == nil && ruolo1 == nil && ruolo2 == nil
	end

end
