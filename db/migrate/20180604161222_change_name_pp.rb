class ChangeNamePp < ActiveRecord::Migration[5.1]
  def change
	rename_table :pps, :uus
  end
end
