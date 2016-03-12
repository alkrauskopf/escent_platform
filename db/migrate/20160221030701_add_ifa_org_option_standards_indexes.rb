class AddIfaOrgOptionStandardsIndexes < ActiveRecord::Migration
  def self.up
    add_index :ifa_org_option_act_masters, [:ifa_org_option_id], :name=>'orgoption'
    add_index :ifa_org_option_act_masters, [:act_master_id, :ifa_org_option_id], :name=>'standard_orgoption'
  end

  def self.down
  end
end
