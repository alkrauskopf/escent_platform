class CreateClassrooms < ActiveRecord::Migration
  def self.up
    create_table :classrooms do |t|
      t.string :course_name
      t.string :subject_area
      t.text :meeting_times
      t.text :text_and_other_material_used
      t.text :course_expectations
      t.string :status,:default => 'active'
      t.integer :organization_id

      t.timestamps
    end
  end

  def self.down
    drop_table :classrooms
  end
end
