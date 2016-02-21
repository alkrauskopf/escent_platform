class AddActScoreRangeIndexes < ActiveRecord::Migration
  def self.up
    remove_index :act_score_ranges, [:act_subject_id]
    remove_index :act_score_ranges, [:act_master_id]
    remove_index :act_score_ranges, [:upper_score]
    add_index :act_score_ranges, [:act_master_id, :act_subject_id], :name => 'standard_subject'
    add_index :act_score_ranges, [:act_subject_id, :act_master_id], :name => 'subject_standard'
  end

  def self.down
  end
end
