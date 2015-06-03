class RenameSubjectAreaCol < ActiveRecord::Migration
  def self.up

  rename_column :classrooms, :subject_area, :subject_area_old
  rename_column :contents, :subject_area, :subject_area_old  
  end

  def self.down

  rename_column :classrooms, :subject_area_old, :subject_area
  rename_column :contents, :subject_area_old , :subject_area   
  end
end
