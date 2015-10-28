class ChangeCourseExceptionsToCourseExpectaionsForClassrooms < ActiveRecord::Migration
  def self.up
    # rename_column :classrooms,:course_exceptions,:course_expectations
  end

  def self.down
    # rename_column :classrooms,:course_expectations,:course_exceptions
  end
end
