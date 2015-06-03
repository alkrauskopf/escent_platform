class RemoveColsFromActGuestions < ActiveRecord::Migration
  def self.up
    remove_column :act_questions, :is_lock
    remove_column :act_choices, :is_correct
  end

  def self.down
    add_column :act_questions, :is_lock, :binary
    add_column :act_choices, :is_correct, :binary
  end
end
