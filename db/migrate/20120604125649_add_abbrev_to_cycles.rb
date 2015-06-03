class AddAbbrevToCycles < ActiveRecord::Migration
  def self.up

   add_column :dle_cycles, :abbrev, :string, :limit => 5

  end

  def self.down

   remove_column :dle_cycles, :abbrev

  end
end
