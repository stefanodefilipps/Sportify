class Pp < ApplicationRecord
	has_many :gioca, dependent: :delete_all
	has_many :user, through: :gioca
	belongs_to :match
end
