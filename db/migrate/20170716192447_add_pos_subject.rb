class AddPosSubject < ActiveRecord::Migration
  def up
    add_column :act_subjects, :pos, :integer, :default => 0
  end

  def down
    remove_column :act_subjects, :pos
  end
end
