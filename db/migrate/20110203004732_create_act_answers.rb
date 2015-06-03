class CreateActAnswers < ActiveRecord::Migration
  def self.up
    create_table :act_answers do |t|
      t.integer :act_taken_assessment_id
      t.integer :act_question_id
      t.integer :act_choice_id
      t.boolean :is_correct
      t.decimal :points

      t.timestamps
    end
  end

  def self.down
    drop_table :act_answers
  end
end
