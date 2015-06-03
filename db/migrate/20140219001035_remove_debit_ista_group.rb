class RemoveDebitIstaGroup < ActiveRecord::Migration
  def self.up
    remove_column  :ista_groups, :drcr
  end

  def self.down
    add_column  :ista_groups, :drcr, :integer
  end
end
