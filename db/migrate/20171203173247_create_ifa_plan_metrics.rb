class CreateIfaPlanMetrics < ActiveRecord::Migration
  def change
    create_table :ifa_plan_metrics do |t|
      t.integer :entity_id
      t.string :entity_type
      t.integer :act_subject_id
      t.boolean :is_uptodate, :default=>true

      t.timestamps
    end
    add_index :ifa_plan_metrics, [:entity_type, :entity_id, :act_subject_id], :name=>'entity_subject'
    add_index :ifa_plan_metrics, [:act_subject_id], :name=>'subject'
  end
end
