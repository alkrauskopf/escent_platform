class AddCycleIdEltCase < ActiveRecord::Migration
  def self.up
   add_column  :elt_cases, :elt_cycle_id, :integer, :null=> false
   
   execute "UPDATE elt_cases SET elt_cycle_id = 1" 
   add_index :elt_cases, [:elt_cycle_id, :grade_level_id], :name=>"cycle_gradelevel"
   add_index :elt_cases, [:organization_id, :elt_cycle_id], :name=>"organization_cycle"
   add_index :elt_cases, [:elt_cycle_id, :user_id], :name=>"cycle_user"
  end

  def self.down
   remove_column  :elt_cases, :elt_cycle_id
  end
end
