class CreatePars < ActiveRecord::Migration[5.1]
  def change
    create_table :pars do |t|
      t.belongs_to :notification, index: true
      t.belongs_to :match, index: true

      t.timestamps
    end
  end
end
