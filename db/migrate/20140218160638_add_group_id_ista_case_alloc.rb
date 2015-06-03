class AddGroupIdIstaCaseAlloc < ActiveRecord::Migration
  def self.up
    add_column  :ista_case_allocations, :ista_group_id, :integer

    add_index :ista_case_allocations, [:ista_group_id]
  end    
  def self.down

    remove_column  :ista_case_allocations, :ista_group_id

  end
end
