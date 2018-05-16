class User < ApplicationRecord
	has_many :gioca
	has_many :pp, through: :gioca
	has_many :s 
	has_many :pt, through: :s
	has_many :membro
	has_many :team, through: :membro
	has_many :compagni, class_name: "User"
end
