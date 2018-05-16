class Team < ApplicationRecord
	has_many :membro
	has_many :user, through: :membro
	belongs_to :capitano, class_name "User"
	has_many :pt
	has_many :tt
end
