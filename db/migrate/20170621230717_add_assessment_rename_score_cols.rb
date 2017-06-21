class AddAssessmentRenameScoreCols < ActiveRecord::Migration
  def up
    rename_column :act_assessments, :lower_score, :min_score
    rename_column :act_assessments, :upper_score, :max_score
  end

  def down
    rename_column :act_assessments, :min_score, :lower_score
    rename_column :act_assessments, :max_score, :upper_score
  end
end
