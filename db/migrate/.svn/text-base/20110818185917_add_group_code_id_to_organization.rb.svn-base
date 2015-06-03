class AddGroupCodeIdToOrganization < ActiveRecord::Migration
  def self.up

  add_column :organizations, :coop_group_code_id, :integer
  add_column :coop_app_rates, :coop_group_code_id, :integer
  remove_column :coop_app_rates, :group_code
  end

  def self.down

  remove_column :organizations, :coop_group_code_id
  remove_column :coop_app_rates, :coop_group_code_id
  add_column :coop_app_rates, :group_code, :string
  
  end
end
