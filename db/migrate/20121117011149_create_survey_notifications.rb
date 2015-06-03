class CreateSurveyNotifications < ActiveRecord::Migration
  def self.up
    create_table :survey_notifications do |t|
      t.integer :tlt_survey_type_id
      t.integer :tlt_survey_audience_id

      t.timestamps
    end
  add_index :survey_notifications, :tlt_survey_type_id
  add_index :survey_notifications, :tlt_survey_audience_id
  end

  def self.down
    drop_table :survey_notifications
  end
end
