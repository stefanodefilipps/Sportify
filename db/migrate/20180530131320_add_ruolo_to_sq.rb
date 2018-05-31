class AddRuoloToSq < ActiveRecord::Migration[5.1]
  def change
  	add_column :sqs, :ruolo, :string
  end
end
