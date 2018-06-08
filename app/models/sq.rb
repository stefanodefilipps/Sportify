class Sq < ApplicationRecord
	belongs_to :notification, dependent: :destroy
	belongs_to :team
end
