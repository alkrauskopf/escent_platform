class CreateIfaPlanMilestoneEvidences < ActiveRecord::Migration
  def change
    create_table :ifa_plan_milestone_evidences do |t|
      t.integer :ifa_plan_milestone_id
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :ifa_plan_milestone_evidences, [:ifa_plan_milestone_id]
  end
end
