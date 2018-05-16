class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.integer :tipo
      t.date :data
      t.time :ora
      t.string :msg
      t.belongs_to :sender, index: true
      t.belongs_to :receiver, index: true

      t.timestamps
    end
  end
end
