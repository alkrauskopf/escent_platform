class AddTeacherOnlyFolder < ActiveRecord::Migration
  def up
    add_column :folder_positions, :for_teacher, :boolean, :default => false
  end

  def down
    remove_column :folder_positions, :for_teacher
  end
end
