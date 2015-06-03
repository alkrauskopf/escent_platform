class CreateAct_scoreRanges < ActiveRecord::Migration
  def self.up
    create_table :act_score_ranges do |t|
      t.integer :act_subject_id
      t.string :range
      t.integer :lower_score
      t.integer :upper_score

      t.timestamps
    end
  end

  def self.down
    drop_table :act_score_ranges
  end
end
