class AddInstructionsToSurvey < ActiveRecord::Migration
  def self.up

  add_column :survey_schedules, :survey_instruction_id, :integer, :default=> 999

  end

  def self.down
  
    remove_column :survey_schedules, :survey_instruction_id
  
  end
end
