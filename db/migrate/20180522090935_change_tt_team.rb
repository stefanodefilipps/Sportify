class ChangeTtTeam < ActiveRecord::Migration[5.1]
  def change
  	rename_table :tts_teams, :teams_tts
  end
end
