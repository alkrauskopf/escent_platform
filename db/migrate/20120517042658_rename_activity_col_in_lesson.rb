class RenameActivityColInLesson < ActiveRecord::Migration
  def self.up
 
    rename_column :tlt_diagnostic_lessons, :tlt_activity_type_id, :tl_activity_type_id
  end

  def self.down

    rename_column :tlt_diagnostic_lessons, :tl_activity_type_id, :tlt_activity_type_id

  end
end
