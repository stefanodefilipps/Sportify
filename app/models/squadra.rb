class Squadra < ApplicationRecord
	validates :ruolo, inclusion: {in: ["A","P","C1","C2","D"]}
	belongs_to :pt 
	belongs_to :user
end
