class AddUserEnabledAltNamesCoopApp < ActiveRecord::Migration
  def self.up
   add_column  :coop_apps, :user_enableable, :boolean, :default=> true
   add_column  :coop_app_organizations, :alt_name, :string, :limit=> 50
   add_column  :coop_app_organizations, :alt_abbrev, :string, :limit=> 6
  end

  def self.down
   remove_column  :coop_app_organizations, :alt_abbrev
   remove_column  :coop_app_organizations, :alt_name
   remove_column  :coop_apps, :user_enableable
  end
end
