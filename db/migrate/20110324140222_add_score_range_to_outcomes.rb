class AddScoreRangeToOutcomes < ActiveRecord::Migration
  def self.up
    
    add_column :act_score_ranges, :standard, :string
    add_column :co_gle_evidence_outcomes, :act_score_range_id, :integer  
    execute "UPDATE act_score_ranges SET standard = 'act'"  
  end

  def self.down
    remove_column :act_score_ranges, :standard
    remove_column :co_gle_evidence_outcomes, :act_score_range_id 
  end
end
