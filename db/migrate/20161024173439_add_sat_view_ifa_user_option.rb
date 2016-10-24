class AddSatViewIfaUserOption < ActiveRecord::Migration
  def up
    add_column :ifa_user_options, :calibrate_only, :boolean, :default => false
    add_column :ifa_user_options, :sat_view, :boolean, :default => false
  end

  def down
    remove_column :ifa_user_options, :calibrate_only
    remove_column :ifa_user_options, :sat_view
  end
end
