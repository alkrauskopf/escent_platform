class AddNameIstaCaseAlloc < ActiveRecord::Migration
  def self.up
    add_column  :ista_case_allocations, :name, :string

  end

  def self.down
    remove_column  :ista_case_allocations, :name
  end
end
