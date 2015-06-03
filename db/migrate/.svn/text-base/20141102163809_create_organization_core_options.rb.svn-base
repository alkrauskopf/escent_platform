class CreateOrganizationCoreOptions < ActiveRecord::Migration
  def self.up
    create_table :organization_core_options do |t|
      t.integer :organization_id
      t.boolean :register_notify, :default => true
      t.boolean :content_notify, :default => true

      t.timestamps
    end
  add_index :organization_core_options, [:organization_id]
  end

  def self.down
    drop_table :organization_core_options
  end
end
