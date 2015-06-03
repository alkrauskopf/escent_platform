class RemoveSurveyType < ActiveRecord::Migration
  def self.up
    remove_column :tlt_survey_questions, :survey_type
  end

  def self.down
    add_column :tlt_survey_questions, :survey_type, :string,:limit => 10
  end
end
