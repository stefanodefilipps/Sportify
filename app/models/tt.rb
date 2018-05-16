class Tt < ApplicationRecord
	belongs_to :match
	has_many :team
end
