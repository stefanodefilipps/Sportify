class ChangeLngAndLatMatch < ActiveRecord::Migration[5.1]
  def change
  	change_table :matches do |t|
  		t.rename :long, :lng
	end
  end
end
