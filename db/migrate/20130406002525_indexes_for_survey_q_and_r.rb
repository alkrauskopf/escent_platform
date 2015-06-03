class IndexesForSurveyQAndR < ActiveRecord::Migration
  def self.up
    remove_index :tlt_survey_questions, :tlt_survey_type_id
    remove_index :tlt_survey_questions, :tlt_survey_audience_id
    remove_index :tlt_survey_questions, :coop_app_id
    remove_index :tlt_survey_questions, :organization_id
    remove_index :tlt_survey_responses, :survey_schedule_id
    remove_index :tlt_survey_responses, :tlt_survey_question_id
    remove_index :tlt_survey_responses, :tlt_session_id
    remove_index :tlt_survey_responses, :user_id
    remove_index :tlt_sessions, :user_id
    remove_index :tlt_sessions, :organization_id
  end

  def self.down
    add_index :tlt_survey_questions, :tlt_survey_type_id
    add_index :tlt_survey_questions, :tlt_survey_audience_id
    add_index :tlt_survey_questions, :coop_app_id
    add_index :tlt_survey_questions, :organization_id
    add_index :tlt_survey_responses, :survey_schedule_id
    add_index :tlt_survey_responses, :tlt_survey_question_id
    add_index :tlt_survey_responses, :tlt_session_id
    add_index :tlt_survey_responses, :user_id
    add_index :tlt_sessions, :user_id
    add_index :tlt_sessions, :organization_id

  end
end
