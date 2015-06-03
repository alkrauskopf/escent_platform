class CleanUpOutreachPrioritiesJoinTables < ActiveRecord::Migration
  def self.up
    drop_table   :user_outreach_priorities
    create_table :outreach_priorities_users, :id => false, :force => true do |t|
      t.integer :outreach_priority_id, :default => 0, :null => false
      t.integer :user_id, :default => 0, :null => false
      t.datetime :created_at
    end
    add_index :outreach_priorities_users, [:outreach_priority_id, :user_id], :unique => true, :name => "index_outreach_priority_id_and_user_id"
    add_index :outreach_priorities_users, [:user_id, :outreach_priority_id], :unique => true, :name => "index_user_id_and_outreach_priority_id"
    
    drop_table   :organizations_outreach_priorities
    create_table :organizations_outreach_priorities, :id => false, :force => true do |t|
      t.integer :outreach_priority_id, :default => 0, :null => false
      t.integer :organization_id, :default => 0, :null => false
      t.datetime :created_at
    end
    add_index :organizations_outreach_priorities, [:outreach_priority_id, :organization_id], :unique => true, :name => "index_outreach_priority_id_and_organization_id"
    add_index :organizations_outreach_priorities, [:organization_id, :outreach_priority_id], :unique => true, :name => "index_organization_id_and_outreach_priority_id"
  end

  def self.down
    rename_table :outreach_priorities_users, :user_outreach_priorities
  end
end
