class Change2NameSquadra < ActiveRecord::Migration[5.1]
  def change
  	rename_table :squadra, :squadras
  end
end
