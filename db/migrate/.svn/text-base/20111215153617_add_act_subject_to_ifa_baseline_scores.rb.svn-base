class AddActSubjectToIfaBaselineScores < ActiveRecord::Migration
  def self.up

   add_column :ifa_user_baseline_scores, :act_subject_id, :integer
   add_index  :ifa_user_baseline_scores, :act_subject_id
   
  end

  def self.down

   remove_column :ifa_user__baseline_scores, :act_subject_id

  end
end
