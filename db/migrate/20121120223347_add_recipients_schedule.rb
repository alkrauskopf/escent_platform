class AddRecipientsSchedule < ActiveRecord::Migration
  def self.up

   add_column :survey_schedules, :recipients, :integer, :default=>1
   add_column :tlt_survey_types, :sequence, :integer

  execute "UPDATE survey_schedules SET recipients = 1"
  end

  def self.down

   remove_column :survey_schedules, :recipients
   remove_column :tlt_survey_types, :sequence
  end
end
