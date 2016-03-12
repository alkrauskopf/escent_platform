class AddIfaUserBaselineScoresIndexes < ActiveRecord::Migration
  def self.up
    remove_index :ifa_user_baseline_scores, [:user_id]
    remove_index :ifa_user_baseline_scores, [:act_master_id]
    remove_index :ifa_user_baseline_scores, [:act_subject_id]
    add_index :ifa_user_baseline_scores, [:user_id, :act_subject_id, :act_master_id], :name => 'user_subject_standard'
    add_index :ifa_user_baseline_scores, [:user_id, :act_master_id, :act_subject_id], :name => 'user_standard_subject'
    add_index :ifa_user_baseline_scores, [:act_master_id, :act_subject_id, :user_id], :name => 'standard_subject_user'
    add_index :ifa_user_baseline_scores, [:act_subject_id, :act_master_id, :user_id], :name => 'subject_standard_user'
  end

  def self.down
  end
end
