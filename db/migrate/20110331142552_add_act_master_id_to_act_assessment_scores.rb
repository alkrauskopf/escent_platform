class AddActMasterIdToActAssessmentScores < ActiveRecord::Migration
  def self.up

    add_column :act_assessment_score_ranges, :act_master_id, :integer
  
  end

  def self.down

    remove_column :act_assessment_score_ranges, :act_master_id
  
  end
end
