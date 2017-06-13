class IfaOrgAddActMaster < ActiveRecord::Migration
  def up
    add_column :ifa_org_options, :act_master_id, :integer
    add_index :ifa_org_options, [:act_master_id]
  end

  def down
    remove_column :ifa_org_options, :act_master_id
  end
end
