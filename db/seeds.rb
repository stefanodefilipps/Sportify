# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = Hash.new
for i in (0..10)
	user["#{i}"] = User.create(nome: "giorgino", cognome: "evangelista", nick: "#{i}", ruolo1: "C", ruolo2: "D2")
end