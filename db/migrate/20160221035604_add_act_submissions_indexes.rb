class AddActSubmissionsIndexes < ActiveRecord::Migration
  def self.up
    remove_index :act_submissions, [:user_id]
    remove_index :act_submissions, [:act_assessment_id]
    remove_index :act_submissions, [:classroom_id]
    remove_index :act_submissions, [:teacher_id]
    remove_index :act_submissions, [:organization_id]
    remove_index :act_submissions, [:act_subject_id]
    remove_index :act_submissions, [:is_final]
    add_index :act_submissions, [:user_id, :is_final]
    add_index :act_submissions, [:act_assessment_id, :is_final]
    add_index :act_submissions, [:classroom_id, :is_final]
    add_index :act_submissions, [:teacher_id, :is_final]
    add_index :act_submissions, [:organization_id, :is_final]
    add_index :act_submissions, [:act_subject_id, :is_final]
    add_index :act_submissions, [:reviewer_id, :is_final]
  end

  def self.down
  end
end
