class CreateGiocas < ActiveRecord::Migration[5.1]
  def change
    create_table :giocas do |t|
      t.string :squadra
      t.string :ruolo
      t.belongs_to :user, index: true
      t.belongs_to :pp, index: true

      t.timestamps
    end

    add_index :giocas, [ :squadra, :ruolo, :pp_id], unique: true
  end
end
