class AddParentIndicators < ActiveRecord::Migration
  def self.up

   add_column  :elt_types, :is_master, :boolean, :default=> false
   add_column  :rubrics, :is_active, :boolean, :default=> true
   add_column  :elt_indicators, :parent_id, :integer
   add_index :elt_indicators, [:parent_id]
  end

  def self.down
   remove_column  :elt_indicators, :parent_id
   remove_column  :rubrics, :is_active
   remove_column  :elt_types, :is_master
  end
end
