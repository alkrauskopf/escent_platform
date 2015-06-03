class AddSurceyTypeToSurveyQuestions < ActiveRecord::Migration
  def self.up
    add_column :tlt_survey_questions, :tlt_survey_type_id, :integer
    add_column :tlt_survey_responses, :tlt_survey_type_id, :integer


    add_index :tlt_survey_questions, :tlt_survey_audience_id
    add_index :tlt_survey_responses, :tlt_survey_audience_id
    add_index :tlt_survey_questions, :tlt_survey_type_id
    add_index :tlt_survey_responses, :tlt_survey_type_id
    
    execute "UPDATE tlt_survey_questions SET tlt_survey_type_id = 1" 
    execute "UPDATE tlt_survey_responses SET tlt_survey_type_id = 1"


  end

  def self.down
    remove_column :tlt_survey_questions, :tlt_survey_type_id
    remove_column :tlt_survey_responses, :tlt_survey_type_id
  end
end
