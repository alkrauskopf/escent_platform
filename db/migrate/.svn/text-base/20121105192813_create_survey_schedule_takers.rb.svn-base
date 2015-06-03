class CreateSurveyScheduleTakers < ActiveRecord::Migration
  def self.up
    create_table :survey_schedule_takers do |t|
      t.integer :survey_schedule_id
      t.integer :taker_id

      t.timestamps
    end
  add_index :survey_schedule_takers, :survey_schedule_id
  add_index :survey_schedule_takers, :taker_id

  end

  def self.down
    drop_table :survey_schedule_takers
  end
end
