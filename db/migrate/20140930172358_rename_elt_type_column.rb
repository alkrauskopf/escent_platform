class RenameEltTypeColumn < ActiveRecord::Migration
  def self.up
    rename_column  :elt_types, :type, :activity  

  end

  def self.down
    rename_column  :elt_types, :activity, :type
  end
end
