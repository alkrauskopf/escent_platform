class RenameOrganizationsOutreachPriorities < ActiveRecord::Migration
  def self.up
    remove_column :organization_outreach_priorities, :created_at
    rename_table :organization_outreach_priorities, :organizations_outreach_priorities
  end

  def self.down
    rename_table :organizations_outreach_priorities, :organization_outreach_priorities
    add_column :organization_outreach_priorities, :created_at, :datetime 
  end
end
