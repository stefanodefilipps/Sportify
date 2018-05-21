class Pt < ApplicationRecord
	belongs_to :match
	has_many :squadra
	has_many :user, through: :squadra
	has_one :team
end
