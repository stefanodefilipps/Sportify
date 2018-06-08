class AddSquadraToPar < ActiveRecord::Migration[5.1]
  def change
      add_column :pars, :squadra, :string
  end
end
