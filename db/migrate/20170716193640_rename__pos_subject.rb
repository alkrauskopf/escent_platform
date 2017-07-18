class RenamePosSubject < ActiveRecord::Migration
  def up
    rename_column :act_subjects, :pos, :posit
  end

  def down
    rename_column :act_subjects, :posit, :pos
  end
end
