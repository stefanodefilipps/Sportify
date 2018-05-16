class Match < ApplicationRecord
	belongs_to :creatore, class_name: "User"
	has_one :pp
	has_one :pt 
	has_one :tt
	
end
