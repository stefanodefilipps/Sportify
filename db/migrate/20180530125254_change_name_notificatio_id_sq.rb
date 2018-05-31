class ChangeNameNotificatioIdSq < ActiveRecord::Migration[5.1]
  def change
  	change_table :sqs do |t|
  		t.rename :notificatio_id, :notification_id
	end
  end
end
