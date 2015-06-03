class RemoveMeetingExpectationsClassroom < ActiveRecord::Migration
  def self.up

     remove_column  :classrooms, :subject_area_old
     remove_column  :classrooms, :meeting_times
     remove_column  :classrooms, :text_and_other_material_used
     remove_column  :classrooms, :course_expectations
  end

  def self.down

     add_column  :classrooms, :subject_area_old, :text
     add_column  :classrooms, :meeting_times, :text
     add_column  :classrooms, :text_and_other_material_used, :text
     add_column  :classrooms, :course_expectations, :text

  end
end
