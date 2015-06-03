class CreateOrganizationDleMetrics < ActiveRecord::Migration
  def self.up
    create_table :organization_dle_metrics do |t|
      t.integer :dle_metric_id
      t.integer :organization_id
      t.string :note

      t.timestamps
    end
  add_index :organization_dle_metrics, [:organization_id, :dle_metric_id]

  end

  def self.down
    drop_table :organization_dle_metrics
  end
end
