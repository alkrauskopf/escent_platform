class RenameSubjectAreaIdInClassroom < ActiveRecord::Migration
  def self.up
    rename_column :classrooms, :subject_area_id, :act_subject_id
    execute "UPDATE classrooms SET act_subject_id = 1"
  end

  def self.down
    rename_column :classrooms, :act_subject_id, :subject_area_id
  end
end
