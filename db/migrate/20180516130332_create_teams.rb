class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :nome
      t.belongs_to :capitano, index: true

      t.timestamps
    end
  end
end
