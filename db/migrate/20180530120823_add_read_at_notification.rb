class AddReadAtNotification < ActiveRecord::Migration[5.1]
  def change
  	add_column :notifications, :read_at, :datetime
  end
end
