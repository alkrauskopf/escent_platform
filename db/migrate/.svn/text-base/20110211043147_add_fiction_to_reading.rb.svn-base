class AddFictionToReading < ActiveRecord::Migration
  def self.up
    add_column :act_rel_readings, :is_fiction, :boolean
    execute "UPDATE act_rel_readings SET is_fiction = 1" 
  end

  def self.down
    remove_column :act_rel_readings, :is_fiction
  end
end
