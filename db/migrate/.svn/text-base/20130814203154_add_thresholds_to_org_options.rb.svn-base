class AddThresholdsToOrgOptions < ActiveRecord::Migration
  def self.up

  add_column  :itl_org_options, :is_thresholds, :boolean

  execute "UPDATE itl_org_options SET is_thresholds = 0"

  end

  def self.down

  remove_column  :itl_org_options, :is_thresholds


  end
end
