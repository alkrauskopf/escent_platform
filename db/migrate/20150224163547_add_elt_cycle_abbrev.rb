class AddEltCycleAbbrev < ActiveRecord::Migration
  def self.up
    add_column :elt_cycles, :abbrev, :text, :limit => 6
  end

  def self.down
    remove_column :elt_cycles, :abbrev
  end
end
