class AddMaxResponsesToSurvey < ActiveRecord::Migration
  def self.up

  add_column :survey_schedules, :max_responses, :integer, :default=> 1000

  end

  def self.down

  remove_column :survey_schedules, :max_responses
  end
end
