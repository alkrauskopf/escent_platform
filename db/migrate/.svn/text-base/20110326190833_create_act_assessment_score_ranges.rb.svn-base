class CreateActAssessmentScoreRanges < ActiveRecord::Migration
  def self.up
    create_table :act_assessment_score_ranges do |t|
      t.integer :act_assessment_id
      t.string :standard
      t.integer :lower_score
      t.integer :upper_score

      t.timestamps
    end
  end

  def self.down
    drop_table :act_assessment_score_ranges
  end
end
