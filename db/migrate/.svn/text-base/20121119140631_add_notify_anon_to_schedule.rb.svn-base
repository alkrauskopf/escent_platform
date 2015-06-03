class AddNotifyAnonToSchedule < ActiveRecord::Migration
  def self.up
   add_column :survey_schedules, :is_notify, :boolean
   add_column :survey_schedules, :is_anon, :boolean

  execute "UPDATE survey_schedules SET is_notify = 0"
  execute "UPDATE survey_schedules SET is_anon = 0"

  end

  def self.down
   remove_column :survey_schedules, :is_notify
   remove_column :survey_schedules, :is_anon
  end
end
