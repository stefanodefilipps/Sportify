class CreateMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :matches do |t|
      t.integer :punt1
      t.integer :punt2
      t.string :campo
      t.date :data
      t.time :ora
      t.float :lat
      t.float :long

      t.timestamps
    end
  end
end
