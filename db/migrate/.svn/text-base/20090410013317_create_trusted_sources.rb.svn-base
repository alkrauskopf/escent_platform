class CreateTrustedSources < ActiveRecord::Migration
  def self.up
    create_table :trusted_sources do |t|
      t.integer  :organization_id
      t.integer  :source_id
      t.string   :type, :limit => 32
      t.timestamps
    end
    add_index :trusted_sources, [:organization_id, :source_id, :type], :unique => true
  end

  def self.down
    drop_table :trusted_sources
  end
end
