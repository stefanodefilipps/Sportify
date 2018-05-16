class CreateSqs < ActiveRecord::Migration[5.1]
  def change
    create_table :sqs do |t|
      t.belongs_to :notificatio, index: true
      t.belongs_to :team, index: true

      t.timestamps
    end
  end
end
