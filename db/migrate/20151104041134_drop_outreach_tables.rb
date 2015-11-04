class DropOutreachTables < ActiveRecord::Migration
  def self.up
    drop_table :outreach_priorities
    drop_table :outreach_priorities_outreach_priority_groups
    drop_table :outreach_priorities_topics
    drop_table :outreach_priorities_users
    drop_table :outreach_priority_groups
    drop_table :organizations_outreach_priorities
  end

  def self.down
  end
end
