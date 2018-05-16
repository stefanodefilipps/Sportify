class ChangeNameUser < ActiveRecord::Migration[5.1]
  def change
  	change_table :users do |t|
  		t.rename :name, :nome
	end
	add_column :users, :nick, :string
  end
end
