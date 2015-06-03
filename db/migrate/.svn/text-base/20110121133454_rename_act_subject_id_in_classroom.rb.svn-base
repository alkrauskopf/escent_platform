class RenameActSubjectIdInClassroom < ActiveRecord::Migration
  def self.up
    rename_column :classrooms, :act_subject_id, :subject_area_id
  end

  def self.down
    rename_column :classrooms, :subject_area_id, :act_subject_id
  end
end
