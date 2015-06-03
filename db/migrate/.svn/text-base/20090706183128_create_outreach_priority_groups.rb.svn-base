class CreateOutreachPriorityGroups < ActiveRecord::Migration
  def self.up
    create_table :outreach_priority_groups do |t|
      t.integer :outreach_priority_id
      t.integer :user_id
      t.integer :organization_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_priority_groups
  end
end
