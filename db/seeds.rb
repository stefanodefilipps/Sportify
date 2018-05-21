# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Pp.delete_all
Gioca.delete_all

matches = Match.create!([{:punt1 => 1, :punt2 => 2, :campo => "nascosa", :lat => 41.4425018, :lng => 12.8676795, :creatore_id => 1},
	{:punt1 => 0, :punt2 => 4, :campo => "capanno", :lat => 41.5215244, :lng => 12.7874466, :creatore_id => 1}])

pps = Pp.create!([{:match_id => 7}])

giocas = Gioca.create!([{:squadra => "A", :ruolo => "C11", :user_id => 1, :pp_id => 3}])