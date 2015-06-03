class AddActToClassroom < ActiveRecord::Migration
  def self.up
    add_column :classrooms, :act_subject_id, :integer
  end

  def self.down
    remove_column :classrooms, :act_subject_id
  end
end
