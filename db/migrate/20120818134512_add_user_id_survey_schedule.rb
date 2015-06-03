class AddUserIdSurveySchedule < ActiveRecord::Migration
  def self.up

  add_column :survey_schedules, :user_id, :integer
  add_column :survey_schedules, :is_active, :boolean, :default=> true  
  add_index :survey_schedules, :user_id

  execute "UPDATE survey_schedules SET is_active = 1" 

  end

  def self.down
  remove_column :survey_schedules, :user_id
  remove_column :survey_schedules, :is_active
  end
end
