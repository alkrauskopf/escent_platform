class DropTrustedSourceTable < ActiveRecord::Migration
  def self.up
    drop_table :trusted_sources
  end

  def self.down
  end
end
