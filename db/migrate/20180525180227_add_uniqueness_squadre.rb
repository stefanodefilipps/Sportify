class AddUniquenessSquadre < ActiveRecord::Migration[5.1]
  def change

  	add_index :membros, [ :user_id, :team_id], unique: true
  	add_index :squadras, [ :pt_id, :user_id], unique: true
  	add_index :giocas, [ :pp_id, :user_id], unique: true

  end
end
