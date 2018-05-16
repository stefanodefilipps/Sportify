class Pp < ApplicationRecord
	has_many :gioca
	has_many :user, through: :gioca
	belongs_to :match
end
