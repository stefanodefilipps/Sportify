class AddAuthUser < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :uid, :string
  	add_column :users, :token, :string
  end
end
