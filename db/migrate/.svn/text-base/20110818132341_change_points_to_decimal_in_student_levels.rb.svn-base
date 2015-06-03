class ChangePointsToDecimalInStudentLevels < ActiveRecord::Migration
  def self.up

  remove_column :ifa_student_levels, :points
  add_column    :ifa_student_levels, :earned_points, :decimal, :precision=>3, :scale=>2
  
  end

  def self.down

  add_column  :ifa_student_levels, :points, :integer
  remove_column :ifa_student_levels,  :earned_points
  
  end
end
