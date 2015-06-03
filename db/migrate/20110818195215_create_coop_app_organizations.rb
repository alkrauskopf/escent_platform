class CreateCoopAppOrganizations < ActiveRecord::Migration
  def self.up
    create_table :coop_app_organizations do |t|
      t.integer :coop_app_id
      t.integer :organization_id

      t.timestamps
    end
  end

  def self.down
    drop_table :coop_app_organizations
  end
end
