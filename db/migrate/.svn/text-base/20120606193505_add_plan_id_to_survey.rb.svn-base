class AddPlanIdToSurvey < ActiveRecord::Migration
  def self.up
    add_column :tlt_survey_responses, :user_dle_plan_id, :integer
    add_index :tlt_survey_responses, :user_dle_plan_id
  end


  def self.down
    remove_column :tlt_survey_responses, :user_dle_plan_id
  end
end
