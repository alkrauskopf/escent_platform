class AssessmentDefaults < ActiveRecord::Migration
  def up
    change_column :act_assessments, :is_locked, :boolean, :default => false
    change_column :act_assessments, :is_active, :boolean, :default => false
    change_column :act_assessments, :is_calibrated, :boolean, :default => false
    change_column :act_assessments, :generation, :integer, :default => 0
  end

  def down
    change_column :act_assessments, :is_locked, :boolean
    change_column :act_assessments, :is_active, :boolean
    change_column :act_assessments, :is_calibrated, :boolean
    change_column :act_assessments, :generation, :integer
  end
end
