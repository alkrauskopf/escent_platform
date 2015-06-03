class CreateActAssessmentClassrooms < ActiveRecord::Migration
  def self.up
    create_table :act_assessment_classrooms do |t|
      t.integer :act_assessment_id
      t.integer :classroom_id
      t.integer :position
      t.integer :display_position

      t.timestamps
    end
  end

  def self.down
    drop_table :act_assessment_classrooms
  end
end
