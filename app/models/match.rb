class Match < ApplicationRecord

	acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng


	belongs_to :creatore, class_name: "User"
	has_one :pp, dependent: :destroy
	has_one :pt, dependent: :destroy
	has_one :tt, dependent: :destroy


	
end
