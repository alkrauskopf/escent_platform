class RenameLockInActQuestion < ActiveRecord::Migration
  def self.up
    rename_column :act_questions, :lock, :is_lock
  end

  def self.down
    rename_column :act_questions, :is_lock, :lock
  end
end
