class AddIndexCoopAppOrg < ActiveRecord::Migration
  def self.up
   add_index :coop_app_organizations, [:coop_app_id, :organization_id], :name=>"app_org"
   add_index :coop_app_organizations, [ :organization_id, :coop_app_id], :name=>"org_app"
  end

  def self.down
   remove_index :coop_app_organizations, [:coop_app_id, :organization_id]
   remove_index :coop_app_organizations, [ :organization_id, :coop_app_id]
  end
end
