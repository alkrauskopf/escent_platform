class IsNotifyIsAnonIntoSurveyInstruction < ActiveRecord::Migration
  def self.up

  add_column  :survey_instructions, :is_notify, :boolean
  add_column  :survey_instructions, :is_anon, :boolean
  add_column  :survey_instructions, :subject_line, :text, :limit => 100

  end

  def self.down

  remove_column  :survey_instructions, :is_notify
  remove_column  :survey_instructions, :is_anon
  remove_column  :survey_instructions, :subject_line
  end
end
