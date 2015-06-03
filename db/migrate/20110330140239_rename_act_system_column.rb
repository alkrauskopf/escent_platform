class RenameActSystemColumn < ActiveRecord::Migration
  def self.up

    rename_column :act_systems, :addrev, :abbrev   
  end

  def self.down

    rename_column :act_systems, :abbrev, :addrev  
  
  end
end
