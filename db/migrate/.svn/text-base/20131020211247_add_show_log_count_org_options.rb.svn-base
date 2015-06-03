class AddShowLogCountOrgOptions < ActiveRecord::Migration
  def self.up

  add_column  :itl_org_options, :log_display_count, :integer

  execute "UPDATE itl_org_options SET log_display_count = 6"

  end

  def self.down

  remove_column  :itl_org_options, :log_display_count

  end
end
