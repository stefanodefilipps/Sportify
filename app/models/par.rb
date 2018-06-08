class Par < ApplicationRecord
	belongs_to :notification, dependent: :destroy
	belongs_to :match
end
