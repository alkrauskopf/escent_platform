class AddTeacherRemarkTltSession < ActiveRecord::Migration
  def self.up
    add_column :tlt_sessions, :teacher_remark, :text

  end

  def self.down
    remove_column :tlt_sessions, :teacher_remark

  end
end
