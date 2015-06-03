class RemoveDebitIstaActivity < ActiveRecord::Migration
  def self.up
    remove_column  :ista_activities, :drcr
    add_column  :ista_groups, :drcr, :integer
  end

  def self.down
    remove_column  :ista_groups, :drcr
    add_column  :ista_activities, :drcr, :integer
  end
end
