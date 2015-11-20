class CreateEltPlanActions < ActiveRecord::Migration
  def self.up
    create_table :elt_plan_actions do |t|
      t.integer :scope_id
      t.string :scope_type,   :limit => 32
      t.integer :elt_plan_id,   :null => false
      t.integer :rubric_id
      t.text :note, :limit=>1024#, :default=>""

      t.timestamps
    end
   add_index :elt_plan_actions, [:scope_type, :scope_id, :elt_plan_id], :name=>"scope_plan"
   add_index :elt_plan_actions, [:elt_plan_id, :scope_type, :scope_id,], :name=>"plan_scope"
   add_index :elt_plan_actions, [:rubric_id, :elt_plan_id,], :name=>"rubric_plan"

  end

  def self.down
    drop_table :elt_plan_actions
  end
end
