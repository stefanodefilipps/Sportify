class Team < ApplicationRecord
	has_many :membro, dependent: :delete_all    #per cancellare dal db a cascata devo usare il metodo team.destroy e non team.delete altrimenti non cancella oggetti associati
	has_many :user, through: :membro
	belongs_to :capitano, class_name: "User"
	has_and_belongs_to_many :pt
	has_and_belongs_to_many :tt
end
