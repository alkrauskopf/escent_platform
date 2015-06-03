class CreateOutreachPrioritiesOutreachPriorityGroups < ActiveRecord::Migration
  def self.up
    create_table :outreach_priorities_outreach_priority_groups, :id => false  do |t|
      t.references :outreach_priority, :outreach_priority_group
      t.datetime :create_at
    end
  end

  def self.down
    drop_table :outreach_priorities_outreach_priority_groups
  end
  
end
