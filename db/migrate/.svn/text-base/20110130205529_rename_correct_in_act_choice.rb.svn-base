class RenameCorrectInActChoice < ActiveRecord::Migration
  def self.up
    rename_column :act_choices, :correct, :is_correct
  end

  def self.down
    rename_column :act_choices, :is_correct, :correct
  end
end
