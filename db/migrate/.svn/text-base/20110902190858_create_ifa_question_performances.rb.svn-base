class CreateIfaQuestionPerformances < ActiveRecord::Migration
  def self.up
    create_table :ifa_question_performances do |t|
      t.integer :act_question_id
      t.integer :act_score_range_id
      t.integer :students
      t.integer :answers
      t.decimal :points, :precision =>8, :scale => 2
      t.integer :calibrated_students
      t.integer :calibrated_student_answers
      t.decimal :calibrated_student_points, :precision =>8, :scale => 2

      t.timestamps
    end
    add_index "ifa_question_performances", "act_question_id"
  
  end

  def self.down
    drop_table :ifa_question_performances
  end
end
