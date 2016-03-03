class ExpandCoopAppOrgLength2 < ActiveRecord::Migration
  def self.up
    change_column :coop_app_organizations, :alt_abbrev, :string, :limit => 9
  end

  def self.down
    change_column :coop_app_organizations, :alt_abbrev, :string, :limit => 6
  end
end
