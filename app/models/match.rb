class Match < ApplicationRecord

	acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng


	belongs_to :creatore, class_name: "User"
	has_one :uu, dependent: :destroy
	has_one :pt, dependent: :destroy
	has_one :tt, dependent: :destroy


	def is_waiting_response_for_role(role,squadra)
		if squadra
			n = Par.where(match_id: self.id, ruolo: role, squadra: squadra)
			return !n.empty?
		end
		n = Par.where(match_id: self.id, ruolo: role)
		return !n.empty?
	end

	def is_waiting_response_for_team
		n = Par.where(match_id: self.id).where.not(team: nil)
		return !n.empty?
	end


	
end
