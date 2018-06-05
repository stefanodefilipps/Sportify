class AddTotVotoUser < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :tot, :integer
  end
end
