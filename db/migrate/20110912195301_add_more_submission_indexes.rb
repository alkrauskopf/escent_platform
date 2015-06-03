class AddMoreSubmissionIndexes < ActiveRecord::Migration
  def self.up

    add_index :act_submissions, :user_id
    add_index :act_submissions, :act_assessment_id
    add_index :act_submissions, :classroom_id
    add_index :act_submissions, :teacher_id
    add_index :act_submissions, :organization_id
    add_index :act_submissions, :act_subject_id
  
  end

  def self.down

    remove_index :act_submissions, :user_id
    remove_index :act_submissions, :act_assessment_id
    remove_index :act_submissions, :classroom_id
    remove_index :act_submissions, :teacher_id
    remove_index :act_submissions, :organization_id
    remove_index :act_submissions, :act_subject_id
  
  end
end
