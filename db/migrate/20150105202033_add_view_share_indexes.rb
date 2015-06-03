class AddViewShareIndexes < ActiveRecord::Migration
  def self.up
    add_index :total_views, [:entity_type, :entity_id]
    remove_column  :total_shares, :entity_type
    add_column  :total_shares, :entity_type, :string, :limit => 32
    add_index :total_shares, [:entity_type, :entity_id]
  end

  def self.down
    remove_index :total_views, [:entity_type, :entity_id]
    remove_index :total_shares, [:entity_type, :entity_id]
  end
end
