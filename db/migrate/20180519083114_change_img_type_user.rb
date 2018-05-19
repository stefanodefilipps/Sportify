class ChangeImgTypeUser < ActiveRecord::Migration[5.1]
  def change
  	change_column :users, :img, :string
  end
end
