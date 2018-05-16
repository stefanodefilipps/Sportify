class CreateS < ActiveRecord::Migration[5.1]
  def change
    create_table :s do |t|
      t.string :ruolo
      t.belongs_to :pt, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
    add_index :s, [ :ruolo, :pt_id], unique: true
  end
end
