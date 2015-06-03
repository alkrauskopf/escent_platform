class AddBaselineScoreToDashboards < ActiveRecord::Migration
  def self.up

   add_column :ifa_dashboard_sms_scores, :baseline_score, :integer
   add_column :ifa_question_performances, :baseline_students, :integer
   add_column :ifa_question_performances, :baseline_answers, :integer
   add_column :ifa_question_performances, :baseline_points, :decimal, :precision =>8, :scale => 2
  end

  def self.down

   remove_column :ifa_dashboard_sms_scores, :baseline_score
   remove_column :ifa_question_performances, :baseline_students
   remove_column :ifa_question_performances, :baseline_answers
   remove_column :ifa_question_performances, :baseline_points
  end
end
