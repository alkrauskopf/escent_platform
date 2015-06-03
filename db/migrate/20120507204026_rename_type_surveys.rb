class RenameTypeSurveys < ActiveRecord::Migration
  def self.up
    rename_column :tlt_survey_questions, :type, :survey_type
  end

  def self.down
    rename_column :tlt_survey_questions, :survey_type, :type
  end
end
