class Notification < ApplicationRecord
	belongs_to :sender, class_name: "User"
	belongs_to :receiver, class_name: "User"
	has_one :sq
	has_one :par
end
