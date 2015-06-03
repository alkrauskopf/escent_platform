class CreateActTakenAssessments < ActiveRecord::Migration
  def self.up
    create_table :act_taken_assessments do |t|
      t.integer :user_id
      t.integer :act_assessment_id
      t.integer :classroom_id
      t.integer :teacher_id
      t.integer :organization_id
      t.boolean :is_final
      t.integer :final_sms
      t.integer :est_sms
      t.timestamp :date_finalized
      t.text :student_comment
      t.text :teacher_comment
      t.integer :max_score

      t.timestamps
    end
  end

  def self.down
    drop_table :act_taken_assessments
  end
end
