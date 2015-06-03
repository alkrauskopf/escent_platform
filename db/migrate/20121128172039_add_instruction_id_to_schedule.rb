class AddInstructionIdToSchedule < ActiveRecord::Migration
  def self.up
    add_index :survey_schedules, :survey_instruction_id
  end

  def self.down

  end
end
