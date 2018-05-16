class CreatePps < ActiveRecord::Migration[5.1]
  def change
    create_table :pps do |t|
      t.belongs_to :match, index: true

      t.timestamps
    end
  end
end
