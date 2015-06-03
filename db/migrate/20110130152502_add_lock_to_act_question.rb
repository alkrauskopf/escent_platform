class AddLockToActQuestion < ActiveRecord::Migration
  def self.up
    add_column :act_questions, :lock, :binary
  end

  def self.down
    remove_column :act_questions, :lock
  end
end
