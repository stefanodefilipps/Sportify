class Notification < ApplicationRecord
	belongs_to :sender, class_name: "User"
	belongs_to :receiver, class_name: "User"
	has_one :sq, dependent: :destroy
	has_one :par, dependent: :destroy

	scope :unread, -> { where(read_at: nil) }
end
