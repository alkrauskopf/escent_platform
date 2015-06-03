class CreateStudentDemographics < ActiveRecord::Migration
  def self.up
    create_table :student_demographics do |t|
      t.integer :user_id
      t.integer :grade_level_base
      t.date :grade_base_date

      t.timestamps
    end
    add_index :student_demographics, :user_id
  end

  def self.down
    drop_table :student_demographics
  end
end
