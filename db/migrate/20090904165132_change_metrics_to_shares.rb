class ChangeMetricsToShares < ActiveRecord::Migration
  def self.up
    rename_table :metrics , :shares
  end

  def self.down
    rename_table :shares , :metrics
  end
end
