class TempOldTemplateIdSession < ActiveRecord::Migration
  def self.up
    add_column   :tlt_sessions,:old_template_id, :integer
    execute "UPDATE tlt_sessions SET old_template_id = itl_template_id"
  end

  def self.down
    remove_column   :tlt_sessions,:old_template_id
  end
end
