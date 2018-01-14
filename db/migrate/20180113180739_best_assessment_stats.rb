class BestAssessmentStats < ActiveRecord::Migration
  def up
    add_column :act_assessments, :shortest_duration, :integer, :default=>0
    add_column :act_assessments, :best_time_per_point, :integer, :default=>0
    add_column :act_assessments, :best_pct, :integer, :default=>0
    add_column :act_assessments, :most_points, :decimal, :precision=>6, :scale=>2, :default=>0.00
  end

  def down
    remove_column :act_assessments, :shortest_duration
    remove_column :act_assessments, :best_time_per_point
    remove_column :act_assessments, :best_pct
    remove_column :act_assessments, :most_points
  end
end
