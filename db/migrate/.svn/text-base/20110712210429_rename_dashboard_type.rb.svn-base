class RenameDashboardType < ActiveRecord::Migration
  def self.up

    rename_column :ifa_dashboards, :ifa_dashboard_type, :ifa_dashboardable_type

  end

  def self.down

    rename_column :ifa_dashboards, :ifa_dashboardable_type, :ifa_dashboard_type

  end
end
