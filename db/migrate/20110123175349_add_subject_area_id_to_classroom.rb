class AddSubjectAreaIdToClassroom < ActiveRecord::Migration
  def self.up
    add_column :classrooms, :subject_area_id, :integer
  end

  def self.down
    remove_column :classrooms, :subject_area_id
  end
end
