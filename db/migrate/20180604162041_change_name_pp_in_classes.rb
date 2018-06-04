class ChangeNamePpInClasses < ActiveRecord::Migration[5.1]
  def change
  	rename_column :giocas, :pp_id, :uu_id
  end
end
