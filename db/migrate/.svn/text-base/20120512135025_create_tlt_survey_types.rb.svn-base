class CreateTltSurveyTypes < ActiveRecord::Migration
  def self.up
    create_table :tlt_survey_types do |t|
      t.string :abbrev, :limit => 5
      t.string :name, :limit => 10
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :tlt_survey_types
  end
end
