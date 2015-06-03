class AddIsOwnerCoopAppOrg < ActiveRecord::Migration
  def self.up

  add_column  :coop_app_organizations, :is_owner, :boolean

  execute "UPDATE coop_app_organizations SET is_owner = 0"


  end

  def self.down

  remove_column  :coop_app_organizations, :is_owner

  end
end
