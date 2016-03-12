class AddActQuestionIndexes < ActiveRecord::Migration
  def self.up
    add_index :act_questions, [:co_standard_id, :co_grade_level_id ], :name => 'co_standard_grade'
    add_index :act_questions, [:co_grade_level_id, :co_standard_id ], :name => 'co_grade_standard'
    add_index :act_questions, [:original_question_id ], :name => 'orig_question'
  end

  def self.down
  end
end
