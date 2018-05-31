class Membro < ApplicationRecord
	validates :ruolo, inclusion: {in: ["A","P","C1","C2","D"]}
	belongs_to :user
	belongs_to :team
end
