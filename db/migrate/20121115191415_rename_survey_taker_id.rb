class RenameSurveyTakerId < ActiveRecord::Migration
  def self.up
     rename_column :survey_schedule_takers, :taker_id, :user_id
  end

  def self.down
     rename_column :survey_schedule_takers, :user_id, :taker_id
  end
end
