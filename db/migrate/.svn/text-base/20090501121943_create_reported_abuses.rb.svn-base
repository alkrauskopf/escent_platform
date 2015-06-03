class CreateReportedAbuses < ActiveRecord::Migration
  # organization_id stores from which organization this abuse was reported from
  def self.up
    create_table :reported_abuses do |t|
      t.integer :entity_id
      t.integer :entity_type
      t.integer :user_id
      t.integer :organization_id
      t.string  :abuse, :limit => 16
      t.timestamps
    end
    add_index :reported_abuses, [:entity_id, :entity_type, :abuse]
  end

  def self.down
    drop_table :reported_abuses
  end
end
