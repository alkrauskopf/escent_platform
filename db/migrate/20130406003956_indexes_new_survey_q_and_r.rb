class IndexesNewSurveyQAndR < ActiveRecord::Migration
  def self.up

    add_index :tlt_survey_responses, [:survey_schedule_id, :tlt_survey_question_id], :name => "survey_question"
    add_index :tlt_survey_responses, [:user_id, :organization_id], :name => "user_organization"
    add_index :tlt_survey_responses, [:tlt_survey_question_id, :score], :name => "question_score"
    add_index :tlt_survey_responses, [:tlt_session_id, :tlt_survey_audience_id], :name => "observation_audience"
    add_index :tlt_survey_responses, [:survey_schedule_id, :user_id], :name => "survey_user"
    add_index :tlt_survey_questions, [:organization_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "org_audience_type"
    add_index :tlt_survey_questions, [:organization_id, :coop_app_id], :name => "org_app"

  end

  def self.down

    remove_index :tlt_survey_responses, [:survey_schedule_id, :tlt_survey_question_id], :name => "survey_question"
    remove_index :tlt_survey_responses, [:user_id, :organization_id], :name => "user_organization"
    remove_index :tlt_survey_responses, [:tlt_survey_question_id, :score], :name => "question_score"
    remove_index :tlt_survey_responses, [:tlt_session_id, :tlt_survey_audience_id], :name => "observation_audience"
    remove_index :tlt_survey_responses, [:survey_schedule_id, :user_id], :name => "survey_user"
    remove_index :tlt_survey_questions, [:organization_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "org_audience_type"
    remove_index :tlt_survey_questions, [:organization_id, :coop_app_id], :name => "org_app"

  end
end
