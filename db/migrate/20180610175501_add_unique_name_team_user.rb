class AddUniqueNameTeamUser < ActiveRecord::Migration[5.1]
  def change
  	add_index :teams, [ :nome], unique: true
  	add_index :users, [ :nick], unique: true
  end
end
