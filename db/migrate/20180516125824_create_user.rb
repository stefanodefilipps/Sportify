class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
    	t.string :name
      	t.string :cognome
      	t.text   :desc
      	t.binary :img
      	t.float  :voto
      	t.string :ruolo1
      	t.string :ruolo2
    end
  end
end
