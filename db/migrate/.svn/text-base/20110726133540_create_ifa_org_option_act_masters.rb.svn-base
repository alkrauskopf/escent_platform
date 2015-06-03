class CreateIfaOrgOptionActMasters < ActiveRecord::Migration
  def self.up
    create_table :ifa_org_option_act_masters do |t|
      t.integer :ifa_org_option_id
      t.integer :act_master_id
      t.boolean :is_default

      t.timestamps
    end
  end

  def self.down
    drop_table :ifa_org_option_act_masters
  end
end
