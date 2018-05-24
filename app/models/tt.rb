class Tt < ApplicationRecord
	belongs_to :match
	has_and_belongs_to_many :team, :limit => 2
end
