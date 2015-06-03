class CreateStudentSubjectDemographics < ActiveRecord::Migration
  def self.up
    create_table :student_subject_demographics do |t|
      t.integer :user_id
      t.integer :act_subject_id
      t.integer :latest_csap

      t.timestamps
    end
    add_index :student_subject_demographics, :user_id
    add_index :student_subject_demographics, :act_subject_id
  end

  def self.down
    drop_table :student_subject_demographics
  end
end
