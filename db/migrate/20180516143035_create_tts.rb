class CreateTts < ActiveRecord::Migration[5.1]
  def change
    create_table :tts do |t|
      t.belongs_to :match, index: true

      t.timestamps
    end
  end 
end
