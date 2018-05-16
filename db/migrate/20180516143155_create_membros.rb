class CreateMembros < ActiveRecord::Migration[5.1]
  def change
    create_table :membros do |t|
      t.string :ruolo
      t.belongs_to :team, index: true 
      t.belongs_to :user, index: true

      t.timestamps
    end
    add_index :membros, [ :team_id, :ruolo], unique: true
  end
end
