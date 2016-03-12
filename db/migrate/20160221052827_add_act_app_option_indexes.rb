class AddActAppOptionIndexes < ActiveRecord::Migration
  def self.up
    add_index :act_app_options, [:organization_id, :act_master_id], :name => 'org_standard'
    add_index :act_app_options, [ :act_master_id, :organization_id], :name => 'standard_org'
  end

  def self.down
  end
end
