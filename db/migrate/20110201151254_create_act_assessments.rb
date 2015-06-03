class CreateActAssessments < ActiveRecord::Migration
  def self.up
    create_table :act_assessments do |t|
      t.string :name
      t.integer :act_subject_id
      t.integer :upper_score
      t.integer :lower_score
      t.text :comment
      t.integer :user_id
      t.integer :organization_id
      t.boolean :is_locked
      t.integer :original_assessment_id
      t.integer :generation

      t.timestamps
    end
  end

  def self.down
    drop_table :act_assessments
  end
end
