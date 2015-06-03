class AddSeqNumIstaActivity < ActiveRecord::Migration
  def self.up
    add_column  :ista_activities, :seq_num, :integer
    add_column  :ista_activities, :is_active, :boolean
  end

  def self.down
    remove_column  :ista_activities, :seq_num
    remove_column  :ista_activities, :is_active
  end
end
