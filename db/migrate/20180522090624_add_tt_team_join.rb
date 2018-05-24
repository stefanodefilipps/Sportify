class AddTtTeamJoin < ActiveRecord::Migration[5.1]
  def change
  	 create_table :tts_teams, id: false do |t|
      t.belongs_to :tt, index: true
      t.belongs_to :team, index: true
    end
  end
end
