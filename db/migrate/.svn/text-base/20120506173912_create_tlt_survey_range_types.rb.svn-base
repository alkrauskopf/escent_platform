class CreateTltSurveyRangeTypes < ActiveRecord::Migration
  def self.up
    create_table :tlt_survey_range_types do |t|
      t.string :label
      t.string :low_end
      t.string :high_end

      t.timestamps
    end
  end

  def self.down
    drop_table :tlt_survey_range_types
  end
end
