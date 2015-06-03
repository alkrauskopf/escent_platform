class AddSelectAllowOrgCoopApps < ActiveRecord::Migration
  def self.up
    add_column  :coop_app_organizations, :is_selected, :boolean, :default => false, :null => false
    add_column  :coop_app_organizations, :is_allowed, :boolean, :default => true, :null => false
    execute "UPDATE coop_app_organizations SET is_selected = 1"
    execute "UPDATE coop_app_organizations SET is_allowed = 1"
  end

  def self.down
    remove_column  :coop_app_organizations, :is_selected
    remove_column  :coop_app_organizations, :is_allowed
  end
end
