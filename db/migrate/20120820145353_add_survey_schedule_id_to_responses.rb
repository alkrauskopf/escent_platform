class AddSurveyScheduleIdToResponses < ActiveRecord::Migration
  def self.up

  add_column :tlt_survey_responses, :survey_schedule_id, :integer

  add_index  :tlt_survey_responses, :survey_schedule_id

  end

  def self.down

  remove_column :tlt_survey_responses, :survey_schedule_id

  end
end
