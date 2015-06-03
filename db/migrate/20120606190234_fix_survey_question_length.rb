class FixSurveyQuestionLength < ActiveRecord::Migration
  def self.up
    rename_column :tlt_survey_questions, :question, :question_old
    add_column  :tlt_survey_questions, :question, :string
    execute "UPDATE tlt_survey_questions SET question = question_old"   
    
  end

  def self.down
    remove_column  :tlt_survey_questions, :question
    rename_column :tlt_survey_questions, :question_old, :question
  end
end
