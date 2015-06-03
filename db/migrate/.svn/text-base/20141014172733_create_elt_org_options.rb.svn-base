class CreateEltOrgOptions < ActiveRecord::Migration
  def self.up
    create_table :elt_org_options do |t|
      t.integer :organization_id
      t.integer :owner_org_id
      t.integer :elt_cycle_id

      t.timestamps
    end
  add_index :elt_org_options, [:organization_id, :owner_org_id, :elt_cycle_id], :name=>"org_ownerorg_cycle"
  add_index :elt_org_options, [ :owner_org_id,:organization_id, :elt_cycle_id], :name=>"ownerorg_org_cycle"
  add_index :elt_org_options, [:organization_id, :elt_cycle_id], :name=>"org_cycle"
  add_index :elt_org_options, [ :elt_cycle_id,:organization_id], :name=>"cycle_org"
  end

  def self.down
    drop_table :elt_org_options
  end
end
