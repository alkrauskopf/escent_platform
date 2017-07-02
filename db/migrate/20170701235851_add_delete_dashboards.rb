class AddDeleteDashboards < ActiveRecord::Migration
  def up
    add_column :ifa_dashboards, :is_replaced, :boolean, :default => false
  end

  def down
    remove_column :ifa_dashboards, :is_replaced
  end
end
