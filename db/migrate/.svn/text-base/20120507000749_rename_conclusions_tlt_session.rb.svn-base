class RenameConclusionsTltSession < ActiveRecord::Migration
  def self.up
    rename_column :tlt_sessions, :conclusions, :coaching_point
    execute "UPDATE tlt_sessions SET coaching_point = ''"
    execute "UPDATE tlt_sessions SET teacher_remark = ''"

  end

  def self.down
    rename_column :tlt_sessions, :coaching_point, :conclusions

  end
end
