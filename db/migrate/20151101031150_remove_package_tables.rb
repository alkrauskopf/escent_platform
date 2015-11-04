class RemovePackageTables < ActiveRecord::Migration
  def self.up
    drop_table :packages
    drop_table :package_subscription_terms
    drop_table :package_tabs
    drop_table :package_types
  end

  def self.down
  end
end
