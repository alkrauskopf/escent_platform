class CreateEltPlanTypes < ActiveRecord::Migration
  def self.up
    create_table :elt_plan_types do |t|
      t.integer :organization_id
      t.string :abbrev, :limit => 8
      t.string :name, :limit => 32
      t.boolean :is_active, :default => true
      t.text :description

      t.timestamps
    end
    add_index :elt_plan_types, [:organization_id], :name => "organization"
  end

  def self.down
    drop_table :elt_plan_types
  end
end
