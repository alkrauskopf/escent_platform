class ExpandCoopAppOrgNameLength < ActiveRecord::Migration
  def change
    change_column :coop_app_organizations, :alt_abbrev, :string, :limit => 9
  end
end
