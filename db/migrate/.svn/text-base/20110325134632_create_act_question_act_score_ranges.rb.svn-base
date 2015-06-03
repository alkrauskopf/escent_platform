class CreateActQuestionActScoreRanges < ActiveRecord::Migration
  def self.up
    create_table :act_question_act_score_ranges do |t|
      t.integer :act_question_id
      t.integer :act_score_range_id

      t.timestamps
    end
 
  end

  def self.down
    drop_table :act_question_act_score_ranges
    
  end
end
