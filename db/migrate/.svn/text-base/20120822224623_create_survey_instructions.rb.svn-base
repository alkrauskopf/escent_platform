class CreateSurveyInstructions < ActiveRecord::Migration
  def self.up
    create_table :survey_instructions do |t|
      t.integer :tlt_survey_audience_id
      t.integer :tlt_survey_type_id
      t.text :instructions

      t.timestamps
    end

  add_index  :survey_instructions, :tlt_survey_audience_id
  add_index  :survey_instructions, :tlt_survey_type_id
  end

  def self.down
    drop_table :survey_instructions
  end
end
