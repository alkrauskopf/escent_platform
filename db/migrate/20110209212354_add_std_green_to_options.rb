class AddStdGreenToOptions < ActiveRecord::Migration
  def self.up
    rename_column  :act_app_options, :std_dashboard_threshold, :std_red_threshold
    add_column  :act_app_options, :std_green_threshold, :decimal, :precision=>3, :scale => 2
    execute "UPDATE act_app_options SET std_green_threshold = .5"

  end

  def self.down
    remove_column :act_app_options, :std_green_threshold
    rename_column  :act_app_options, :std_red_threshold, :std_dashboard_threshold
  end
end