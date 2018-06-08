class Team < ApplicationRecord
	validate :in_range
	has_many :membro, dependent: :delete_all, autosave: true  #per cancellare dal db a cascata devo usare il metodo team.destroy e non team.delete altrimenti non cancella oggetti associati
	has_many :user, through: :membro
	belongs_to :capitano, class_name: "User"
	has_and_belongs_to_many :pt
	has_and_belongs_to_many :tt
	has_many :sq, dependent: :delete_all
	has_many :notification, through: :sq

	def roles_left
		roles = ["A","C1","C2","D","P"]
		self.membro.each do |m|
			roles.delete_if {|r| r == m.ruolo}
		end
		return roles
	end

	def is_in_team?(user)
		self.membro.each do |m|
			if m.user.id == user.id
				return true
			end
		end
		return false
	end

	#Questo metodo mi serve solo per sapere se alcuni ruoli sono in attesa di risposta da una notifica per team

	def is_waiting_response_for_role(user,role)
		n = Sq.where(team_id: self.id, ruolo: role)
		return !n.empty?
	end

	private 

	def in_range
		if self.user.size > 5
			errors.add(:size_limit, "una squadra non può avere più di 5 membri")
			throw :abort
		end
	end
end
