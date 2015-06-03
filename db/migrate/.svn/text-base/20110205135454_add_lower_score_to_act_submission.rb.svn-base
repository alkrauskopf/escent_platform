class AddLowerScoreToActSubmission < ActiveRecord::Migration
  def self.up
    add_column :act_submissions, :lower_score_bound,:integer
    rename_column :act_submissions, :max_score, :upper_score_bound
  end

  def self.down
    remove_column :act_submissions, :lower_score_bound
    rename_column :act_submissions, :upper_score_bound, :max_score
  end
end
