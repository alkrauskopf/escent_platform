class AddActAssessRangeIndexes < ActiveRecord::Migration
  def self.up
    remove_index :act_assessment_score_ranges, [:act_assessment_id]
    remove_index :act_assessment_score_ranges, [:act_master_id]
    remove_index :act_assessment_score_ranges, [:upper_score]
    add_index :act_assessment_score_ranges, [:act_master_id, :act_assessment_id], :name => 'standard_assess'
    add_index :act_assessment_score_ranges, [:act_assessment_id, :act_master_id], :name => 'assess_standard'
  end

  def self.down
  end
end
