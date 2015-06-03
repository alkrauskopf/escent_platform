class AddScheduleLinkItlOptions < ActiveRecord::Migration
  def self.up
    add_column :itl_org_options, :schedule_url, :string, :limit=>250, :default=>""
    add_column :itl_org_options, :schedule_label, :string, :limit=>250, :default=>""

    execute "UPDATE itl_org_options SET schedule_url = ''"
    execute "UPDATE itl_org_options SET schedule_label = ''"
  end

  def self.down
    remove_column :itl_org_options, :schedule_url
    remove_column :itl_org_options, :schedule_label
  end
end
