class Pt < ApplicationRecord
	belongs_to :match
	has_many :s 
	has_many :user, through: :s
	has_one :team
end
