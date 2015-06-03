class AddOrgIdToSnapshot < ActiveRecord::Migration
  def self.up
    add_column :act_snapshots, :organization_id, :integer
  end

  def self.down

    remove_column :act_snapshots, :organization_id

  end
end
