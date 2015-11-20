class ReduceUserTable < ActiveRecord::Migration
  def self.up
    remove_column  :users, :religious_affiliation_id
  end

  def self.down
    add_column  :users, :religious_affiliation_id, :integer
  end
end
