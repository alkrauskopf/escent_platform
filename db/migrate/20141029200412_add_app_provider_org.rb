class AddAppProviderOrg < ActiveRecord::Migration
  def self.up
   add_column  :coop_app_organizations, :provider_id, :integer
   
   add_index :coop_app_organizations, [:provider_id, :organization_id, :coop_app_id], :name=>"provider_org_app"
   add_index :coop_app_organizations, [:provider_id, :coop_app_id, :organization_id], :name=>"provider_app_org"
   add_index :coop_app_organizations, [:organization_id, :provider_id, :coop_app_id], :name=>"org_provider_app"

  end

  def self.down
   remove_column  :coop_app_organizations, :provider_id
  end
end
