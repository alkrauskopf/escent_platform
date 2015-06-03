class CreateActQuestions < ActiveRecord::Migration
  def self.up
    create_table :act_questions do |t|
      t.integer :act_subject_id
      t.integer :act_standard_id
      t.integer :act_score_range_id
      t.integer :act_rel_reading_id
      t.text :question
      t.string :comment
      t.integer :user_id
      t.integer :organization_id
      t.binary :auto_correct

      t.timestamps
    end
  end

  def self.down
    drop_table :act_questions
  end
end
