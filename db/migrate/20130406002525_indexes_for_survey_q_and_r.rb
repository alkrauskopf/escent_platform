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
    add_index :tlt_survey_questions, :tlt_survey_type_id, :name => 'question_type'
    add_index :tlt_survey_questions, :tlt_survey_audience_id, :name => 'survey_audience'
    add_index :tlt_survey_questions, :coop_app_id, :name => 'coop_app'
    add_index :tlt_survey_questions, :organization_id, :name => 'organization'
    add_index :tlt_survey_responses, :survey_schedule_id, :name => 'survey_schedule'
    add_index :tlt_survey_responses, :tlt_survey_question_id, :name => 'survey_question'
    add_index :tlt_survey_responses, :tlt_session_id, :name => 'session'
    add_index :tlt_survey_responses, :user_id, :name => 'user'
    add_index :tlt_sessions, :user_id, :name => 'user'
    add_index :tlt_sessions, :organization_id, :name => 'organization'

  end
end
