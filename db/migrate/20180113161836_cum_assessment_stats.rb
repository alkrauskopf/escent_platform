class CumAssessmentStats < ActiveRecord::Migration
  def up
    add_column :act_assessments, :cum_submissions, :integer, :default=>0
    add_column :act_assessments, :cum_questions_asked, :integer, :default=>0
    add_column :act_assessments, :cum_choices_made, :integer, :default=>0
    add_column :act_assessments, :cum_points_earned, :decimal, :precision=>8, :scale=>0, :default=>0.0
  end

  def down
    remove_column :act_assessments, :cum_submissions
    remove_column :act_assessments, :cum_questions_asked
    remove_column :act_assessments, :cum_choices_made
    remove_column :act_assessments, :cum_points_earned
  end
end
