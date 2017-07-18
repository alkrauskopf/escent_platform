class RenameSubjectIsActive < ActiveRecord::Migration
  def up
    rename_column :act_subjects, :is_active, :is_enabled
  end

  def down
    rename_column :act_subjects, :is_enabled, :is_active
  end
end
