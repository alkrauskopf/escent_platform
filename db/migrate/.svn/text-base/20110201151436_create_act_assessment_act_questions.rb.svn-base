class CreateActAssessmentActQuestions < ActiveRecord::Migration
  def self.up
    create_table :act_assessment_act_questions do |t|
      t.integer :act_assessment_id
      t.integer :act_question_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :act_assessment_act_questions
  end
end
