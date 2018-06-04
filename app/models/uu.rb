class Uu < ApplicationRecord
	has_many :gioca, dependent: :destroy
	has_many :user, through: :gioca
	belongs_to :match
end
