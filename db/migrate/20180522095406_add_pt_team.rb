class AddPtTeam < ActiveRecord::Migration[5.1]
  def change
  	 create_table :pts_teams, id: false do |t|
      t.belongs_to :pt, index: true
      t.belongs_to :team, index: true
     end 
  end
end
