class CreateIfaPlanMilestones < ActiveRecord::Migration
  def change
    create_table :ifa_plan_milestones do |t|
      t.integer :ifa_plan_id
      t.integer :act_standard_id
      t.integer :act_score_range_id
      t.boolean :is_achieved, :default => false
      t.text :description

      t.timestamps
    end
    add_index :ifa_plan_milestones, [:ifa_plan_id, :act_standard_id, :act_score_range_id], :name=>'plan_standard_range'
    add_index :ifa_plan_milestones, [:act_standard_id, :ifa_plan_id], :name=>'standard_range'
    add_index :ifa_plan_milestones, [:act_score_range_id, :ifa_plan_id], :name=>'range_standard'
  end
end
