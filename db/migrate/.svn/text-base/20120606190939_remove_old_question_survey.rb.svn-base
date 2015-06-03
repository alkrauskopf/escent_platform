class RemoveOldQuestionSurvey < ActiveRecord::Migration
  def self.up
    remove_column  :tlt_survey_questions, :question_old
  end

  def self.down
    add_column  :tlt_survey_questions, :question_old, :string
  end
end
