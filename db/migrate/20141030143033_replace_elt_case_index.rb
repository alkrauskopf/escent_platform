class ReplaceEltCaseIndex < ActiveRecord::Migration
  def self.up
   remove_index :elt_cases, [:organization_id, :elt_cycle_id]
   add_index :elt_cases, [:organization_id, :elt_cycle_id, :elt_type_id], :name=>"organization_cycle_activity"
  end

  def self.down
   remove_index :elt_cases, [:organization_id, :elt_cycle_id, :elt_type_id]
   add_index :elt_cases, [:organization_id, :elt_cycle_id], :name=>"organization_cycle"
  end
end
