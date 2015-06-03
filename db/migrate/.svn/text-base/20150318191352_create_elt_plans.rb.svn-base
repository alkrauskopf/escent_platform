class CreateEltPlans < ActiveRecord::Migration
  def self.up
    create_table :elt_plans do |t|
      t.integer :organization_id
      t.integer :elt_cycle_id
      t.boolean :is_open, :default => true

      t.timestamps
    end
   add_index :elt_plans, [:organization_id, :elt_cycle_id], :name=>"organization_cycle"
   add_index :elt_plans, [:elt_cycle_id, :organization_id], :name=>"cycle_organization"
  end

  def self.down
    drop_table :elt_plans
  end
end
