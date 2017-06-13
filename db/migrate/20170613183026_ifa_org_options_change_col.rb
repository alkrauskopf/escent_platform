class IfaOrgOptionsChangeCol < ActiveRecord::Migration
  def up
    remove_column :ifa_org_options, :act_master_id
    add_column :ifa_org_options, :standard_id, :integer
    add_index :ifa_org_options, [:standard_id]
  end

  def down
    remove_column :ifa_org_options, :standard_id
    add_column :ifa_org_options, :act_master_id, :integer
    add_index :ifa_org_options, [:act_master_id]
  end
end
