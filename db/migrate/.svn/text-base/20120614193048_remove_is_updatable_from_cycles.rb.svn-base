class RemoveIsUpdatableFromCycles < ActiveRecord::Migration
  def self.up
     remove_column  :dle_cycles, :is_updateable
  end

  def self.down
     add_column  :dle_cycles, :is_updateable, :boolean

  end
end
