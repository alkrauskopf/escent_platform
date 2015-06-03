class AddIsSelfSurveyToInstruction < ActiveRecord::Migration
  def self.up
   add_column  :survey_instructions, :is_self_survey, :boolean
  end

  def self.down
   remove_column  :survey_instructions, :is_self_survey
  end
end
