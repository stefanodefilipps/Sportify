class ChangeNameS < ActiveRecord::Migration[5.1]
  def change
  	rename_table :s, :squadra
  end
end
