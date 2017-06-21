class AddAssessmentLevelBounds < ActiveRecord::Migration
  def up
    add_column :act_assessments, :lower_level_id, :integer
    add_column :act_assessments, :upper_level_id, :integer
    add_index :act_assessments, [:lower_level_id]
    add_index :act_assessments, [:upper_level_id]
  end

  def down
    remove_column :act_assessments, :lower_level_id
    remove_column :act_assessments, :upper_level_id
  end
end
