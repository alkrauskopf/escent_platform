class ChangeEltStandardsLimits < ActiveRecord::Migration
  def self.up
    change_column :elt_standards, :abbrev, :text, :limit => 8
    change_column :elt_standards, :name, :text, :limit => 120
  end

  def self.down
    change_column :elt_standards, :abbrev, :text, :limit => 255
    change_column :elt_standards, :name, :text, :limit => 255
  end
end
