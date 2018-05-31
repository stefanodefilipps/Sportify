class Team < ApplicationRecord
	validate :in_range
	has_many :membro, dependent: :delete_all, autosave: true  #per cancellare dal db a cascata devo usare il metodo team.destroy e non team.delete altrimenti non cancella oggetti associati
	has_many :user, through: :membro
	belongs_to :capitano, class_name: "User"
	has_and_belongs_to_many :pt
	has_and_belongs_to_many :tt

	def roles_left
		roles = ["A","C1","C2","D","P"]
		self.membro.each do |m|
			roles.delete_if {|r| r == m.ruolo}
		end
		return roles
	end

	private 

	def in_range
		if self.user.size > 5
			errors.add(:size_limit, "una squadra non può avere più di 5 membri")
			throw :abort
		end
	end
end
