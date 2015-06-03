class RemoveIsFiction < ActiveRecord::Migration
  def self.up
    remove_column :act_rel_readings, :is_fiction
  end

  def self.down
    add_column :act_rel_readings, :is_fiction, :boolean 
  end
end
