class MaxRecipientsIntoSurveyInstruction < ActiveRecord::Migration
  def self.up
   add_column  :survey_instructions, :max_recipients, :integer
  end

  def self.down
   remove_column  :survey_instructions, :max_recipients
  end
end
