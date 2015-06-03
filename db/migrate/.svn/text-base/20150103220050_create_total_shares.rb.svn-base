class CreateTotalShares < ActiveRecord::Migration
  def self.up
    create_table :total_shares do |t|
      t.integer :entity_id
      t.text :entity_type, :limit => 32
      t.integer :shares, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :total_shares
  end
end
