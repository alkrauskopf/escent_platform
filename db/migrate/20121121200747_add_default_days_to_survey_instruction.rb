class AddDefaultDaysToSurveyInstruction < ActiveRecord::Migration
  def self.up
   add_column  :survey_instructions, :default_days, :integer
  end

  def self.down
   remove_column  :survey_instructions, :default_days
  end
end
