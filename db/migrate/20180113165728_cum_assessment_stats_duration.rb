class CumAssessmentStatsDuration < ActiveRecord::Migration
  def up
    add_column :act_assessments, :cum_duration, :integer, :default=>0
  end

  def down
    remove_column :act_assessments, :cum_duration
  end
end
