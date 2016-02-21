class AddActAssessIndexes < ActiveRecord::Migration
  def self.up
    remove_index :act_assessments, [:act_subject_id]
    add_index :act_assessments, [:act_subject_id, :is_active, :is_calibrated], :name => 'subject_active_cal'
    add_index :act_assessments, [:act_subject_id, :is_calibrated, :is_active], :name => 'subject_cal_active'
    add_index :act_assessments, [:original_assessment_id], :name => 'orig_assess'
  end

  def self.down
  end
end
