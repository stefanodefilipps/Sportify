class AddRuoloToPar < ActiveRecord::Migration[5.1]
  def change
  	add_column :pars, :ruolo, :string
  end
end
