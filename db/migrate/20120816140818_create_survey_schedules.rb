class CreateSurveySchedules < ActiveRecord::Migration
  def self.up
    create_table :survey_schedules do |t|
      t.integer :entity_id
      t.string :entity_type, :limit => 32
      t.integer :organization_id
      t.integer :tlt_survey_audience_id
      t.integer :tlt_survey_type_id
      t.integer :subject_area_id
      t.date :schedule_start
      t.date :schedule_end

      t.timestamps
    end
  add_index :survey_schedules, :entity_id
  add_index :survey_schedules, :entity_type
  add_index :survey_schedules, :organization_id
  add_index :survey_schedules, :tlt_survey_audience_id
  add_index :survey_schedules, :tlt_survey_type_id
  add_index :survey_schedules, :subject_area_id
  end

  def self.down
    drop_table :survey_schedules
  end
end
